module Pages.Forms.SendAdhoc exposing (Model, Msg(UpdateDate), init, initialModel, update, view)

import Css
import Data exposing (Recipient)
import Date
import DateTimePicker
import FilteringTable exposing (textToRegex)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View as FV exposing (contentField, form, sendButton, timeField)
import Helpers exposing (calculateSmsCost, toggleSelectedPk)
import Html exposing (Html)
import Pages.Forms.Meta.SendAdhoc exposing (meta)
import Regex
import RemoteList as RL


init : Model -> Cmd Msg
init model =
    DateTimePicker.initialCmd initSendAdhocDate model.datePickerState


initSendAdhocDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendAdhocDate state maybeDate =
    UpdateDate state maybeDate


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
    Html.div []
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
    Html.div [ Css.px_4, Css.py_3, Css.bg_blue, Css.text_white ]
        [ Html.p [] [ Html.text "Looks like you don't have any contacts yet." ]
        , props.newContactButton
        ]


sendForm : Props msg -> Model -> RL.RemoteList Recipient -> FormStatus -> Html msg
sendForm props model contacts status =
    let
        fields =
            [ Field meta.content <| contentField props.smsCharLimit (props.form << UpdateContent) model.content
            , Field meta.scheduled_time <| timeField (updateSADate props) model.datePickerState model.date
            , Field meta.recipients <| contactsField props model contacts
            ]
                |> List.map FormField
    in
    form status fields props.postForm (sendButton model.cost)


updateSADate : Props msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateSADate props state maybeDate =
    props.form <| UpdateDate state maybeDate



-- Contacts Multi Select


contactsField : Props msg -> Model -> RL.RemoteList Recipient -> FieldMeta -> List (Html msg)
contactsField props model contacts meta_ =
    FV.multiSelectField
        (FV.MultiSelectField
            contacts
            (Just model.selectedContacts)
            Nothing
            model.adhocFilter
            (props.form << UpdateAdhocFilter)
            (contactView props)
            (contactLabelView props)
        )
        meta_


contactLabelView : Props msg -> Maybe (List Int) -> Recipient -> Html msg
contactLabelView props _ contact =
    FV.multiSelectItemLabelHelper
        .full_name
        (props.form <| ToggleSelectedContact contact.pk)
        contact


contactView : Props msg -> Maybe (List Int) -> Recipient -> Html msg
contactView props maybeSelectedPks contact =
    FV.multiSelectItemHelper
        { itemToStr = .full_name
        , maybeSelectedPks = maybeSelectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = props.form << ToggleSelectedContact
        , itemToId = .pk >> toString >> (++) "contact"
        }
        contact
