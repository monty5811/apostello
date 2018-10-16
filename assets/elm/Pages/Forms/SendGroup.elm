module Pages.Forms.SendGroup exposing (Model, Msg(..), getParams, init, initialModel, update, view)

import Css
import Data exposing (RecipientGroup, UserProfile, nullGroup)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Form as F
import Helpers exposing (calculateSmsCost, onClick)
import Html exposing (Html)
import Html.Attributes as A
import Html.Keyed
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.SendGroup exposing (meta)
import Regex
import RemoteList as RL
import Urls



-- Init


init : Model -> Cmd Msg
init model =
    case F.getDirty model.form of
        Just sg ->
            DateTimePicker.initialCmd initSendGroupDate sg.datePickerState

        Nothing ->
            Cmd.none


initSendGroupDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendGroupDate state maybeDate =
    InputMsg <| UpdateSGDate state maybeDate


getParams : Model -> ( Maybe String, Maybe Int )
getParams { form } =
    case F.getCurrent form of
        Nothing ->
            ( Nothing, Nothing )

        Just sg ->
            ( Just sg.content, sg.selectedPk )



-- Model


type alias Model =
    { form : F.Form SendGroupModel DirtyState
    }


initialModel : Maybe String -> Maybe Int -> Model
initialModel initialContent initialSelectedGroup =
    let
        sgm =
            initialSendGroupModel initialContent initialSelectedGroup
    in
    { form = F.startCreating sgm initialDirtyState
    }


type alias SendGroupModel =
    { content : String
    , date : Maybe Date.Date
    , selectedPk : Maybe Int
    }


initialSendGroupModel : Maybe String -> Maybe Int -> SendGroupModel
initialSendGroupModel initialContent initialSelectedGroup =
    { content = Maybe.withDefault "" initialContent
    , selectedPk = initialSelectedGroup
    , date = Nothing
    }


type alias DirtyState =
    { groupFilter : Regex.Regex
    , datePickerState : DateTimePicker.State
    }


initialDirtyState : DirtyState
initialDirtyState =
    { groupFilter = Regex.regex ""
    , datePickerState = DateTimePicker.initialState
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type InputMsg
    = UpdateSGContent String
    | UpdateSGDate DateTimePicker.State (Maybe Date.Date)
    | SelectGroup Int
    | UpdateGroupFilter String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    , outboundUrl : String
    , scheduledUrl : String
    , groups : List RecipientGroup
    , userPerms : UserProfile
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        InputMsg inputMsg ->
            F.UpdateResp
                { model | form = F.updateField (updateInput inputMsg) model.form }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postCmd props.csrftoken model)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            case F.getCurrent model.form |> Maybe.andThen .date of
                Nothing ->
                    F.okFormRespUpdate { props | successPageUrl = props.outboundUrl } resp model

                Just _ ->
                    case props.userPerms.user.is_staff of
                        True ->
                            F.okFormRespUpdate { props | successPageUrl = props.scheduledUrl } resp model

                        False ->
                            F.okFormRespUpdate { props | successPageUrl = props.outboundUrl } resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> SendGroupModel -> DirtyState -> ( SendGroupModel, DirtyState )
updateInput msg model dirty =
    case msg of
        UpdateSGContent text ->
            ( { model | content = text }, dirty )

        UpdateSGDate state maybeDate ->
            ( { model | date = maybeDate }, { dirty | datePickerState = state } )

        SelectGroup pk ->
            ( { model | selectedPk = Just pk }, dirty )

        UpdateGroupFilter text ->
            ( model, { dirty | groupFilter = textToRegex text } )


calculateCost : List RecipientGroup -> F.Item SendGroupModel -> Maybe Float
calculateCost groups itemState =
    let
        sgm =
            F.itemGetCurrent itemState
    in
    case sgm.content of
        "" ->
            Nothing

        c ->
            case sgm.selectedPk of
                Nothing ->
                    Nothing

                Just pk ->
                    let
                        groupCost =
                            groups
                                |> List.filter (\x -> x.pk == pk)
                                |> List.head
                                |> Maybe.withDefault nullGroup
                                |> .cost
                    in
                    Just (calculateSmsCost groupCost c)


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    case F.getCurrent model.form of
        Just sg ->
            let
                body =
                    [ ( "content", Encode.string sg.content )
                    , ( "recipient_group", Encode.int (Maybe.withDefault 0 sg.selectedPk) )
                    , ( "scheduled_time", Encode.encodeMaybeDate sg.date )
                    ]
            in
            DjangoSend.rawPost csrf Urls.api_act_send_group body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none



-- View


type alias Props msg =
    { form : InputMsg -> msg
    , postForm : msg
    , newGroupButton : Html msg
    , smsCharLimit : Int
    , groups : RL.RemoteList RecipientGroup
    }


view : Props msg -> Model -> Html msg
view props model =
    Html.div []
        [ case props.groups of
            RL.FinalPageReceived groups_ ->
                if List.length groups_ == 0 then
                    noGroups props

                else
                    sendForm props model

            _ ->
                sendForm props model
        ]


noGroups : Props msg -> Html msg
noGroups props =
    Html.div []
        [ Html.p [] [ Html.text "Looks like you don't have any (non-empty) groups yet." ]
        , props.newGroupButton
        ]


sendForm : Props msg -> Model -> Html msg
sendForm props { form } =
    F.form
        form
        (fieldsHelp props)
        props.postForm
        (\sgm -> F.sendButton <| calculateCost (RL.toList props.groups) sgm)


fieldsHelp : Props msg -> F.Item SendGroupModel -> DirtyState -> List (F.FormItem msg)
fieldsHelp props item tmpState =
    [ F.Field meta.content <|
        F.contentField props.smsCharLimit
            { getValue = .content
            , item = item
            , onInput = props.form << UpdateSGContent
            }
    , F.Field meta.scheduled_time <| F.dateTimeField (updateSGDate props) tmpState.datePickerState .date item
    , F.Field meta.recipient_group <| groupField props (F.itemGetCurrent item) tmpState
    ]
        |> List.map F.FormField


updateSGDate : Props msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateSGDate props state maybeDate =
    props.form <| UpdateSGDate state maybeDate


groupField : Props msg -> SendGroupModel -> DirtyState -> F.FieldMeta -> List (Html msg)
groupField props local dirty meta_ =
    [ Html.label [ A.for meta_.id, Css.label ] [ Html.text meta_.label ]
    , Html.div []
        [ loadingMessageOrFilter props
        , Html.div []
            (props.groups
                |> RL.toList
                |> List.filter (filterRecord dirty.groupFilter)
                |> List.map (groupItem props local.selectedPk)
            )
        ]
    , F.helpLabel { help = Just "Note that empty groups are not shown here." }
    ]


loadingMessageOrFilter : Props msg -> Html msg
loadingMessageOrFilter props =
    case props.groups of
        RL.NotAsked _ ->
            Html.text ""

        RL.FinalPageReceived _ ->
            filterInput (props.form << UpdateGroupFilter)

        RL.RespFailed err _ ->
            Html.div [] [ Html.text err ]

        RL.WaitingForFirstResp _ ->
            Html.div [] [ Html.text "We are fetching your groups now..." ]

        RL.WaitingForPage _ ->
            Html.div [] [ Html.text "We are fetching your groups now..." ]

        RL.WaitingOnRefresh _ ->
            Html.text ""


groupItem : Props msg -> Maybe Int -> RecipientGroup -> Html msg
groupItem props selectedPk group =
    Html.Keyed.node "div"
        [ onClick <| props.form <| SelectGroup group.pk
        , A.id "groupItem"
        , Css.cursor_pointer
        ]
        [ ( toString group.pk, groupItemHelper selectedPk group ) ]


groupItemHelper : Maybe Int -> RecipientGroup -> Html msg
groupItemHelper selectedPk group =
    Html.div
        [ Css.border_b_2 ]
        [ Html.span []
            [ selectedIcon selectedPk group
            , Html.text <| group.name ++ " - " ++ group.description
            ]
        , Html.span [ A.class "float-right" ] [ Html.text <| "($" ++ toString group.cost ++ ")" ]
        ]


selectedIcon : Maybe Int -> RecipientGroup -> Html msg
selectedIcon selectedPk group =
    case selectedPk of
        Nothing ->
            Html.text ""

        Just pk ->
            case pk == group.pk of
                True ->
                    Html.i [ A.class "fa fa-check" ] []

                False ->
                    Html.text ""
