module Pages.Forms.SendAdhoc exposing (Model, Msg(..), init, initialModel, update, view)

import Css
import Data exposing (Recipient, UserProfile)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (textToRegex)
import Form as F exposing (Field, FieldMeta, FormItem(FormField), FormStatus(NoAction), contentField, form, sendButton, timeField)
import Helpers exposing (calculateSmsCost, toggleSelectedPk)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.SendAdhoc exposing (meta)
import Regex
import RemoteList as RL
import Urls


init : Model -> Cmd Msg
init model =
    DateTimePicker.initialCmd initSendAdhocDate model.datePickerState


initSendAdhocDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendAdhocDate state maybeDate =
    InputMsg <| UpdateDate state maybeDate


type alias Model =
    { content : String
    , selectedContacts : List Int
    , date : Maybe Date.Date
    , adhocFilter : Regex.Regex
    , cost : Maybe Float
    , datePickerState : DateTimePicker.State
    , formStatus : FormStatus
    }


initialModel : Maybe String -> Maybe (List Int) -> Model
initialModel maybeContent maybePks =
    { content = Maybe.withDefault "" maybeContent
    , selectedContacts = Maybe.withDefault [] maybePks
    , date = Nothing
    , adhocFilter = Regex.regex ""
    , cost = Nothing
    , datePickerState = DateTimePicker.initialState
    , formStatus = NoAction
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type InputMsg
    = UpdateContent String
    | UpdateDate DateTimePicker.State (Maybe Date.Date)
    | ToggleSelectedContact Int
    | UpdateAdhocFilter String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , twilioCost : Float
    , outboundUrl : String
    , scheduledUrl : String
    , successPageUrl : String
    , userPerms : UserProfile
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        InputMsg inputMsg ->
            F.UpdateResp
                (updateInput inputMsg model |> updateCost props.twilioCost)
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
            let
                newLoc =
                    case model.date of
                        Nothing ->
                            props.outboundUrl

                        Just _ ->
                            case props.userPerms.user.is_staff of
                                True ->
                                    props.scheduledUrl

                                False ->
                                    props.outboundUrl
            in
            F.okFormRespUpdate { props | successPageUrl = newLoc } resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> Model -> Model
updateInput msg model =
    case msg of
        UpdateContent text ->
            { model | content = text }

        UpdateDate state maybeDate ->
            { model | date = maybeDate, datePickerState = state }

        ToggleSelectedContact pk ->
            { model | selectedContacts = toggleSelectedPk pk model.selectedContacts }

        UpdateAdhocFilter text ->
            { model | adhocFilter = textToRegex text }


updateCost : Float -> Model -> Model
updateCost twilioCost model =
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


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipients", Encode.list (model.selectedContacts |> List.map Encode.int) )
            , ( "scheduled_time", Encode.encodeMaybeDate model.date )
            ]
    in
    DjangoSend.rawPost csrf Urls.api_act_send_adhoc body
        |> Http.send ReceiveFormResp



-- View


type alias Props msg =
    { form : InputMsg -> msg
    , postForm : msg
    , newContactButton : Html msg
    , smsCharLimit : Int
    }


view : Props msg -> Model -> RL.RemoteList Recipient -> Html msg
view props model contacts =
    Html.div []
        [ case contacts of
            RL.FinalPageReceived contacts_ ->
                if List.length contacts_ == 0 then
                    noContacts props
                else
                    sendForm props model contacts model.formStatus

            _ ->
                sendForm props model contacts model.formStatus
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
    F.multiSelectField
        (F.MultiSelectField
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
    F.multiSelectItemLabelHelper
        .full_name
        (props.form <| ToggleSelectedContact contact.pk)
        contact


contactView : Props msg -> Maybe (List Int) -> Recipient -> Html msg
contactView props maybeSelectedPks contact =
    F.multiSelectItemHelper
        { itemToStr = .full_name
        , maybeSelectedPks = maybeSelectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = props.form << ToggleSelectedContact
        , itemToId = .pk >> toString >> (++) "contact"
        }
        contact
