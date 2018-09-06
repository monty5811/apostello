module Pages.Forms.SendGroup exposing (Model, Msg(..), init, initialModel, update, view)

import Css
import Data exposing (RecipientGroup, UserProfile, nullGroup)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Form as F exposing (Field, FieldMeta, FormItem(FormField), FormStatus(NoAction), contentField, form, sendButton, timeField)
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
    DateTimePicker.initialCmd initSendGroupDate model.datePickerState


initSendGroupDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendGroupDate state maybeDate =
    InputMsg <| UpdateSGDate state maybeDate



-- Model


type alias Model =
    { content : String
    , date : Maybe Date.Date
    , selectedPk : Maybe Int
    , cost : Maybe Float
    , groupFilter : Regex.Regex
    , datePickerState : DateTimePicker.State
    , formStatus : FormStatus
    }


initialModel : Maybe String -> Maybe Int -> Model
initialModel initialContent initialSelectedGroup =
    { content = Maybe.withDefault "" initialContent
    , selectedPk = initialSelectedGroup
    , date = Nothing
    , cost = Nothing
    , groupFilter = Regex.regex ""
    , datePickerState = DateTimePicker.initialState
    , formStatus = NoAction
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
                (updateInput inputMsg model |> updateCost props.groups)
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
            case model.date of
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


updateInput : InputMsg -> Model -> Model
updateInput msg model =
    case msg of
        UpdateSGContent text ->
            { model | content = text }

        UpdateSGDate state maybeDate ->
            { model | date = maybeDate, datePickerState = state }

        SelectGroup pk ->
            { model | selectedPk = Just pk }

        UpdateGroupFilter text ->
            { model | groupFilter = textToRegex text }


updateCost : List RecipientGroup -> Model -> Model
updateCost groups model =
    case model.content of
        "" ->
            { model | cost = Nothing }

        c ->
            case model.selectedPk of
                Nothing ->
                    { model | cost = Nothing }

                Just pk ->
                    let
                        groupCost =
                            groups
                                |> List.filter (\x -> x.pk == pk)
                                |> List.head
                                |> Maybe.withDefault nullGroup
                                |> .cost
                    in
                    { model | cost = Just (calculateSmsCost groupCost c) }


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipient_group", Encode.int (Maybe.withDefault 0 model.selectedPk) )
            , ( "scheduled_time", Encode.encodeMaybeDate model.date )
            ]
    in
    DjangoSend.rawPost csrf Urls.api_act_send_group body
        |> Http.send ReceiveFormResp



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
                    sendForm props model model.formStatus

            _ ->
                sendForm props model model.formStatus
        ]


noGroups : Props msg -> Html msg
noGroups props =
    Html.div []
        [ Html.p [] [ Html.text "Looks like you don't have any (non-empty) groups yet." ]
        , props.newGroupButton
        ]


sendForm : Props msg -> Model -> FormStatus -> Html msg
sendForm props model status =
    let
        fields =
            [ Field meta.content <| contentField props.smsCharLimit (props.form << UpdateSGContent) model.content
            , Field meta.scheduled_time <| timeField (updateSGDate props) model.datePickerState model.date
            , Field meta.recipient_group <| groupField props model props.groups
            ]
                |> List.map FormField
    in
    form status fields props.postForm (sendButton model.cost)


updateSGDate : Props msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateSGDate props state maybeDate =
    props.form <| UpdateSGDate state maybeDate


groupField : Props msg -> Model -> RL.RemoteList RecipientGroup -> FieldMeta -> List (Html msg)
groupField props model groups meta_ =
    [ Html.label [ A.for meta_.id, Css.label ] [ Html.text meta_.label ]
    , Html.div []
        [ loadingMessageOrFilter props groups
        , Html.div []
            (groups
                |> RL.toList
                |> List.filter (filterRecord model.groupFilter)
                |> List.map (groupItem props model.selectedPk)
            )
        ]
    , F.helpLabel { help = Just "Note that empty groups are not shown here." }
    ]


loadingMessageOrFilter : Props msg -> RL.RemoteList a -> Html msg
loadingMessageOrFilter props rl =
    case rl of
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
