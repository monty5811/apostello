module Pages.Forms.SendAdhoc exposing (Model, Msg(..), getParams, init, initialModel, update, view)

import Css
import Data exposing (Recipient, UserProfile)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (textToRegex)
import Form as F
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
    case F.getDirty model.form of
        Just sa ->
            DateTimePicker.initialCmd initSendAdhocDate sa.datePickerState

        Nothing ->
            Cmd.none


initSendAdhocDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendAdhocDate state maybeDate =
    InputMsg <| UpdateDate state maybeDate


type alias Model =
    { form : F.Form SendAdhocModel DirtyState
    }


type alias SendAdhocModel =
    { content : String
    , selectedContacts : List Int
    , date : Maybe Date.Date
    }


type alias DirtyState =
    { datePickerState : DateTimePicker.State
    , adhocFilter : Regex.Regex
    }


initialModel : Maybe String -> Maybe (List Int) -> Model
initialModel maybeContent maybePks =
    let
        sam =
            initialSendAdhocModel maybeContent maybePks
    in
    { form = F.startCreating sam initialDirtyState
    }


initialSendAdhocModel : Maybe String -> Maybe (List Int) -> SendAdhocModel
initialSendAdhocModel maybeContent maybePks =
    { content = Maybe.withDefault "" maybeContent
    , selectedContacts = Maybe.withDefault [] maybePks
    , date = Nothing
    }


initialDirtyState : DirtyState
initialDirtyState =
    { adhocFilter = Regex.regex ""
    , datePickerState = DateTimePicker.initialState
    }


getParams : Model -> ( Maybe String, Maybe (List Int) )
getParams { form } =
    case F.getCurrent form of
        Nothing ->
            ( Nothing, Nothing )

        Just sam ->
            ( Just <| sam.content, Just <| sam.selectedContacts )



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
            let
                newLoc =
                    case F.getCurrent model.form |> Maybe.andThen .date of
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


updateInput : InputMsg -> SendAdhocModel -> DirtyState -> ( SendAdhocModel, DirtyState )
updateInput msg model dirty =
    case msg of
        UpdateContent text ->
            ( { model | content = text }, dirty )

        UpdateDate state maybeDate ->
            ( { model | date = maybeDate }, { dirty | datePickerState = state } )

        ToggleSelectedContact pk ->
            ( { model | selectedContacts = toggleSelectedPk pk model.selectedContacts }, dirty )

        UpdateAdhocFilter text ->
            ( model, { dirty | adhocFilter = textToRegex text } )


calculateCost : Float -> F.Item SendAdhocModel -> Maybe Float
calculateCost twilioCost itemState =
    let
        model =
            F.itemGetCurrent itemState
    in
    case model.content of
        "" ->
            Nothing

        c ->
            case List.length model.selectedContacts of
                0 ->
                    Nothing

                n ->
                    Just (calculateSmsCost (twilioCost * toFloat n) c)


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    case F.getCurrent model.form of
        Just sam ->
            let
                body =
                    [ ( "content", Encode.string sam.content )
                    , ( "recipients", Encode.list (sam.selectedContacts |> List.map Encode.int) )
                    , ( "scheduled_time", Encode.encodeMaybeDate sam.date )
                    ]
            in
            DjangoSend.rawPost csrf Urls.api_act_send_adhoc body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none



-- View


type alias Props msg =
    { form : InputMsg -> msg
    , postForm : msg
    , newContactButton : Html msg
    , smsCharLimit : Int
    , twilioCost : Float
    , contacts : RL.RemoteList Recipient
    }


view : Props msg -> Model -> Html msg
view props model =
    Html.div []
        [ case props.contacts of
            RL.FinalPageReceived contacts_ ->
                if List.length contacts_ == 0 then
                    noContacts props

                else
                    sendForm props model

            _ ->
                sendForm props model
        ]


noContacts : Props msg -> Html msg
noContacts props =
    Html.div [ Css.px_4, Css.py_3, Css.bg_blue, Css.text_white ]
        [ Html.p [] [ Html.text "Looks like you don't have any contacts yet." ]
        , props.newContactButton
        ]


sendForm : Props msg -> Model -> Html msg
sendForm props { form } =
    F.form
        form
        (fieldsHelp props)
        props.postForm
        (\sam -> F.sendButton <| calculateCost props.twilioCost sam)


fieldsHelp : Props msg -> F.Item SendAdhocModel -> DirtyState -> List (F.FormItem msg)
fieldsHelp props item tmpState =
    [ F.Field meta.content <|
        F.contentField
            props.smsCharLimit
            { getValue = .content
            , item = item
            , onInput = props.form << UpdateContent
            }
    , F.Field meta.scheduled_time <|
        F.dateTimeField
            (updateSADate props)
            tmpState.datePickerState
            .date
            item
    , F.Field meta.recipients <|
        contactsField
            props
            item
            tmpState
    ]
        |> List.map F.FormField


updateSADate : Props msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateSADate props state maybeDate =
    props.form <| UpdateDate state maybeDate



-- Contacts Multi Select


contactsField : Props msg -> F.Item SendAdhocModel -> DirtyState -> F.FieldMeta -> List (Html msg)
contactsField props item tmpState meta_ =
    F.multiSelectField
        { items = props.contacts
        , getPks = .selectedContacts
        , item = item
        , filter = tmpState.adhocFilter
        , filterMsg = props.form << UpdateAdhocFilter
        , itemView = contactView props
        , selectedView = contactLabelView props
        }
        meta_


contactLabelView : Props msg -> List Int -> Recipient -> Html msg
contactLabelView props _ contact =
    F.multiSelectItemLabelHelper
        .full_name
        (props.form <| ToggleSelectedContact contact.pk)
        contact


contactView : Props msg -> List Int -> Recipient -> Html msg
contactView props selectedPks contact =
    F.multiSelectItemHelper
        { itemToStr = .full_name
        , selectedPks = selectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = props.form << ToggleSelectedContact
        , itemToId = .pk >> toString >> (++) "contact"
        }
        contact
