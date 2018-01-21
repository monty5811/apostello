module Pages.Forms.SendGroup exposing (Model, Msg(UpdateSGDate), init, initialModel, update, view)

import Data exposing (RecipientGroup, nullGroup)
import Date
import DateTimePicker
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (contentField, form, sendButton, timeField)
import Helpers exposing (calculateSmsCost, onClick)
import Html exposing (Html, div, i, label, p, text)
import Html.Attributes as A exposing (class, for, style)
import Html.Keyed
import Pages.Forms.Meta.SendGroup exposing (meta)
import Regex
import RemoteList as RL


-- Init


init : Model -> Cmd Msg
init model =
    DateTimePicker.initialCmd initSendGroupDate model.datePickerState


initSendGroupDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendGroupDate state maybeDate =
    UpdateSGDate state maybeDate



-- Model


type alias Model =
    { content : String
    , date : Maybe Date.Date
    , selectedPk : Maybe Int
    , cost : Maybe Float
    , groupFilter : Regex.Regex
    , datePickerState : DateTimePicker.State
    }


initialModel : Maybe String -> Maybe Int -> Model
initialModel initialContent initialSelectedGroup =
    { content = Maybe.withDefault "" initialContent
    , selectedPk = initialSelectedGroup
    , date = Nothing
    , cost = Nothing
    , groupFilter = Regex.regex ""
    , datePickerState = DateTimePicker.initialState
    }



-- Update


type Msg
    = UpdateSGContent String
    | UpdateSGDate DateTimePicker.State (Maybe Date.Date)
    | SelectGroup Int
    | UpdateGroupFilter String


update : List RecipientGroup -> Msg -> Model -> Model
update groups msg model =
    updateHelp msg model
        |> updateCost groups


updateHelp : Msg -> Model -> Model
updateHelp msg model =
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



-- View


type alias Props msg =
    { form : Msg -> msg
    , postForm : msg
    , newGroupButton : Html msg
    , smsCharLimit : Int
    }


view : Props msg -> Model -> RL.RemoteList RecipientGroup -> FormStatus -> Html msg
view props model groups status =
    div []
        [ case groups of
            RL.FinalPageReceived groups_ ->
                if List.length groups_ == 0 then
                    noGroups props
                else
                    sendForm props model groups status

            _ ->
                sendForm props model groups status
        ]


noGroups : Props msg -> Html msg
noGroups props =
    div [ class "segment" ]
        [ p [] [ text "Looks like you don't have any (non-empty) groups yet." ]
        , props.newGroupButton
        ]


sendForm : Props msg -> Model -> RL.RemoteList RecipientGroup -> FormStatus -> Html msg
sendForm props model groups status =
    let
        fields =
            [ Field meta.content <| contentField props.smsCharLimit (props.form << UpdateSGContent) model.content
            , Field meta.recipient_group <| groupField props model groups
            , Field meta.scheduled_time <| timeField (updateSGDate props) model.datePickerState model.date
            ]
                |> List.map FormField
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields props.postForm (sendButton model.cost)
        ]


updateSGDate : Props msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateSGDate props state maybeDate =
    props.form <| UpdateSGDate state maybeDate


groupField : Props msg -> Model -> RL.RemoteList RecipientGroup -> FieldMeta -> List (Html msg)
groupField props model groups meta_ =
    [ label [ for meta_.id ] [ text meta_.label ]
    , div [ class "segment" ]
        [ loadingMessage groups
        , filterInput (props.form << UpdateGroupFilter)
        , div
            [ class "list"
            , style
                [ ( "min-height", "25vh" )
                , ( "max-height", "50vh" )
                , ( "overflow-y", "auto" )
                ]
            ]
            (groups
                |> RL.toList
                |> List.filter (filterRecord model.groupFilter)
                |> List.map (groupItem props model.selectedPk)
            )
        ]
    , Html.p [ class "input-hint" ] [ p [] [ text "Note that empty groups are not shown here." ] ]
    ]


loadingMessage : RL.RemoteList a -> Html msg
loadingMessage rl =
    case rl of
        RL.NotAsked _ ->
            text ""

        RL.FinalPageReceived _ ->
            text ""

        RL.RespFailed err _ ->
            div [ class "alert" ] [ text err ]

        RL.WaitingForFirstResp _ ->
            div [ class "alert" ] [ text "We are fetching your groups now..." ]

        RL.WaitingForPage _ ->
            div [ class "alert" ] [ text "We are fetching your groups now..." ]

        RL.WaitingOnRefresh _ ->
            text ""


groupItem : Props msg -> Maybe Int -> RecipientGroup -> Html msg
groupItem props selectedPk group =
    Html.Keyed.node "div"
        [ class "item", onClick <| props.form <| SelectGroup group.pk, A.id "groupItem" ]
        [ ( toString group.pk, groupItemHelper selectedPk group ) ]


groupItemHelper : Maybe Int -> RecipientGroup -> Html msg
groupItemHelper selectedPk group =
    div [ style [ ( "color", "#000" ) ] ]
        [ Html.span [ class "float-right" ] [ text <| "($" ++ toString group.cost ++ ")" ]
        , Html.span []
            [ selectedIcon selectedPk group
            , text <| group.name ++ " - " ++ group.description
            ]
        ]


selectedIcon : Maybe Int -> RecipientGroup -> Html msg
selectedIcon selectedPk group =
    case selectedPk of
        Nothing ->
            text ""

        Just pk ->
            case pk == group.pk of
                True ->
                    i
                        [ class "fa fa-check"
                        , style [ ( "color", "var(--color-purple)" ) ]
                        ]
                        []

                False ->
                    text ""
