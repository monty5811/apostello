module Pages.Forms.SendAdhoc exposing (Model, Msg(UpdateDate), initialModel, update, view)

import Data exposing (Recipient)
import Date
import DateTimePicker
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (contentField, form, sendButton, timeField)
import Helpers exposing (calculateSmsCost, onClick, toggleSelectedPk)
import Html exposing (Html, div, i, label, p, text)
import Html.Attributes as A
import Html.Keyed
import Pages.Forms.Meta.SendAdhoc exposing (meta)
import Regex
import RemoteList as RL
import Rocket exposing ((=>))


type alias Model =
    { content : String
    , selectedContacts : List Int
    , date : Maybe Date.Date
    , adhocFilter : Regex.Regex
    , cost : Maybe Float
    , datePickerState : DateTimePicker.State
    }


initialModel : Maybe String -> Maybe (List Int) -> Model
initialModel maybeContent maybePks =
    { content = Maybe.withDefault "" maybeContent
    , selectedContacts = Maybe.withDefault [] maybePks
    , date = Nothing
    , adhocFilter = Regex.regex ""
    , cost = Nothing
    , datePickerState = DateTimePicker.initialState
    }



-- Update


type Msg
    = UpdateContent String
    | UpdateDate DateTimePicker.State (Maybe Date.Date)
    | ToggleSelectedContact Int
    | UpdateAdhocFilter String


update : Maybe { a | sendingCost : Float } -> Msg -> Model -> Model
update twilioSettings msg model =
    updateHelp msg model
        |> updateCost twilioSettings


updateHelp : Msg -> Model -> Model
updateHelp msg model =
    case msg of
        -- form display:
        UpdateContent text ->
            { model | content = text }

        UpdateDate state maybeDate ->
            { model | date = maybeDate, datePickerState = state }

        ToggleSelectedContact pk ->
            { model | selectedContacts = toggleSelectedPk pk model.selectedContacts }

        UpdateAdhocFilter text ->
            { model | adhocFilter = textToRegex text }


updateCost : Maybe { a | sendingCost : Float } -> Model -> Model
updateCost twilioSettings model =
    case Maybe.map .sendingCost twilioSettings of
        Nothing ->
            { model | cost = Nothing }

        Just twilioCost ->
            case model.content of
                "" ->
                    { model | cost = Nothing }

                c ->
                    case model.selectedContacts |> List.length of
                        0 ->
                            { model | cost = Nothing }

                        n ->
                            { model
                                | cost = Just (calculateSmsCost (twilioCost * toFloat n) c)
                            }



-- View


type alias Props msg =
    { form : Msg -> msg
    , postForm : msg
    , newContactButton : Html msg
    , smsCharLimit : Int
    }


view : Props msg -> Model -> RL.RemoteList Recipient -> FormStatus -> Html msg
view props model contacts status =
    div []
        [ case contacts of
            RL.FinalPageReceived contacts_ ->
                if List.length contacts_ == 0 then
                    noContacts props
                else
                    sendForm props model contacts status

            _ ->
                sendForm props model contacts status
        ]


noContacts : Props msg -> Html msg
noContacts props =
    div [ A.class "segment" ]
        [ p [] [ text "Looks like you don't have any contacts yet." ]
        , props.newContactButton
        ]


sendForm : Props msg -> Model -> RL.RemoteList Recipient -> FormStatus -> Html msg
sendForm props model contacts status =
    let
        fields =
            [ Field meta.content <| contentField props.smsCharLimit (props.form << UpdateContent) model.content
            , Field meta.recipients <| contactsField props model contacts
            , Field meta.scheduled_time <| timeField (updateSADate props) model.datePickerState model.date
            ]
                |> List.map FormField
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields props.postForm (sendButton model.cost)
        ]


updateSADate : Props msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateSADate props state maybeDate =
    props.form <| UpdateDate state maybeDate



-- Contacts Dropdown


loadingMessage : RL.RemoteList a -> Html msg
loadingMessage rl =
    case rl of
        RL.NotAsked _ ->
            text ""

        RL.FinalPageReceived _ ->
            text ""

        RL.RespFailed err _ ->
            div [ A.class "alert" ] [ text err ]

        RL.WaitingForFirstResp _ ->
            div [ A.class "alert" ] [ text "We are fetching your contacts now..." ]

        RL.WaitingForPage _ ->
            div [ A.class "alert" ] [ text "We are fetching your contacts now..." ]

        RL.WaitingOnRefresh _ ->
            text ""


contactsField : Props msg -> Model -> RL.RemoteList Recipient -> FieldMeta -> List (Html msg)
contactsField props model contacts meta_ =
    [ label [ A.for meta_.id ] [ text meta_.label ]
    , div [ A.class "segment" ]
        [ loadingMessage contacts
        , selectedContacts props model.selectedContacts contacts
        , filterInput (props.form << UpdateAdhocFilter)
        , div
            [ A.class "list"
            , A.style
                [ "min-height" => "25vh"
                , "max-height" => "50vh"
                , "overflow-y" => "auto"
                ]
            ]
            (contacts
                |> RL.toList
                |> List.filter (filterRecord model.adhocFilter)
                |> List.map (contactItem props model.selectedContacts)
            )
        ]
    ]


selectedContacts : Props msg -> List Int -> RL.RemoteList Recipient -> Html msg
selectedContacts props selectedPks contacts_ =
    let
        selected =
            contacts_
                |> RL.toList
                |> List.filter (\c -> List.member c.pk selectedPks)
                |> List.map (contactLabel props)
    in
    Html.div [ A.style [ "margin-bottom" => "1rem" ] ] selected


contactLabel : Props msg -> Recipient -> Html msg
contactLabel props contact =
    Html.div
        [ A.class "badge"
        , A.style [ "user-select" => "none" ]
        , onClick <| props.form <| ToggleSelectedContact contact.pk
        ]
        [ Html.text contact.full_name ]


contactItem : Props msg -> List Int -> Recipient -> Html msg
contactItem props selectedPks contact =
    Html.Keyed.node "div"
        [ A.class "item"
        , onClick <| props.form <| ToggleSelectedContact contact.pk
        , A.id "contactItem"
        ]
        [ ( toString contact.pk, contactItemHelper selectedPks contact ) ]


contactItemHelper : List Int -> Recipient -> Html msg
contactItemHelper selectedPks contact =
    div [ A.style [ "color" => "#000" ] ]
        [ selectedIcon selectedPks contact
        , text contact.full_name
        ]


selectedIcon : List Int -> Recipient -> Html msg
selectedIcon selectedPks contact =
    case List.member contact.pk selectedPks of
        False ->
            text ""

        True ->
            i [ A.class "fa fa-check", A.style [ "color" => "var(--color-purple)" ] ] []
