module Forms.Update exposing (update)

import Data.Keyword exposing (Keyword)
import Data.Recipient exposing (Recipient)
import Data.RecipientGroup exposing (RecipientGroup)
import Date
import DjangoSend exposing (rawPost)
import Encode exposing (encodeDate, encodeMaybe, encodeMaybeDate)
import Forms.Model exposing (FormErrors, FormStatus(Failed, InProgress, Success), decodeFormResp, formDecodeError, noErrors)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (FormMsg(..), Msg(FormMsg))
import Models exposing (CSRFToken, Model)
import Navigation as Nav
import Pages as P
import Pages.ContactForm.Model exposing (ContactFormModel)
import Pages.Fragments.Notification.Update as Notif
import Pages.GroupForm.Model exposing (GroupFormModel)
import Pages.KeywordForm.Model exposing (KeywordFormModel)
import Pages.SendAdhocForm.Model exposing (SendAdhocModel)
import Pages.SendGroupForm.Model exposing (SendGroupModel)
import Pages.SiteConfigForm.Model exposing (SiteConfigFormModel)
import Route exposing (page2loc)
import Time
import Urls


update : FormMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        PostKeywordForm kfModel maybeKeyword ->
            ( { model | formStatus = InProgress }, [ postKeywordForm model.currentTime model.settings.csrftoken kfModel maybeKeyword ] )

        PostContactForm cfModel maybeContact ->
            ( { model | formStatus = InProgress }, [ postContactForm model.settings.csrftoken cfModel maybeContact ] )

        PostGroupForm gfModel maybeGroup ->
            ( { model | formStatus = InProgress }, [ postGroupForm model.settings.csrftoken gfModel maybeGroup ] )

        PostAdhocForm saModel ->
            case saModel.cost of
                Nothing ->
                    ( model, [] )

                Just _ ->
                    ( { model | formStatus = InProgress }, [ postAdhocForm model.settings.csrftoken saModel ] )

        PostSGForm sgModel ->
            case sgModel.cost of
                Nothing ->
                    ( model, [] )

                Just _ ->
                    ( { model | formStatus = InProgress }, [ postSGForm model.settings.csrftoken sgModel ] )

        PostSiteConfigForm scModel ->
            ( { model | formStatus = InProgress }, [ postSCForm model.settings.csrftoken scModel ] )

        ReceiveFormResp okMsg (Ok resp) ->
            case Decode.decodeString decodeFormResp resp.body of
                Ok data ->
                    ( { model | formStatus = Success } |> Notif.addListOfDjangoMessagesNoDestroy data.messages
                    , okMsg
                    )

                Err err ->
                    ( { model | formStatus = Failed <| formDecodeError err }, [] )

        ReceiveFormResp _ (Err err) ->
            case err of
                Http.BadStatus resp ->
                    case Decode.decodeString decodeFormResp resp.body of
                        Ok data ->
                            ( { model | formStatus = Failed data.errors } |> Notif.addListOfDjangoMessagesNoDestroy data.messages
                            , []
                            )

                        Err e ->
                            ( { model | formStatus = Failed <| formDecodeError e }
                                |> Notif.addListOfDjangoMessagesNoDestroy [ Notif.refreshNotifMessage ]
                            , []
                            )

                _ ->
                    ( { model | formStatus = Failed noErrors }
                        |> Notif.addListOfDjangoMessagesNoDestroy [ Notif.refreshNotifMessage ]
                    , []
                    )


postAdhocForm : CSRFToken -> SendAdhocModel -> Cmd Msg
postAdhocForm csrftoken model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipients", Encode.list (model.selectedContacts |> List.map Encode.int) )
            , ( "scheduled_time", encodeMaybeDate model.date )
            ]

        newLoc =
            case model.date of
                Nothing ->
                    P.OutboundTable

                Just _ ->
                    P.ScheduledSmsTable
    in
    rawPost csrftoken Urls.api_act_send_adhoc body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc newLoc ])


postSGForm : CSRFToken -> SendGroupModel -> Cmd Msg
postSGForm csrftoken model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipient_group", Encode.int (Maybe.withDefault 0 model.selectedPk) )
            , ( "scheduled_time", encodeMaybeDate model.date )
            ]

        newLoc =
            case model.date of
                Nothing ->
                    P.OutboundTable

                Just _ ->
                    P.ScheduledSmsTable
    in
    rawPost csrftoken Urls.api_act_send_group body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc newLoc ])


postGroupForm : CSRFToken -> GroupFormModel -> Maybe RecipientGroup -> Cmd Msg
postGroupForm csrftoken model maybeGroup =
    let
        body =
            [ ( "name", Encode.string <| extractField .name model.name maybeGroup )
            , ( "description", Encode.string <| extractField .description model.description maybeGroup )
            ]
                |> addPk maybeGroup
    in
    rawPost csrftoken Urls.api_recipient_groups body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.GroupTable False ])


extractField : (a -> String) -> Maybe String -> Maybe a -> String
extractField fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing group or default to ""
            Maybe.map fn maybeRec
                |> Maybe.withDefault ""

        Just s ->
            s


postContactForm : CSRFToken -> ContactFormModel -> Maybe Recipient -> Cmd Msg
postContactForm csrftoken model maybeContact =
    let
        body =
            [ ( "first_name", Encode.string <| extractField .first_name model.first_name maybeContact )
            , ( "last_name", Encode.string <| extractField .last_name model.last_name maybeContact )
            , ( "number", Encode.string <| extractField (Maybe.withDefault "" << .number) model.number maybeContact )
            , ( "do_not_reply", Encode.bool <| extractBool .do_not_reply model.do_not_reply maybeContact )
            ]
                |> addPk maybeContact
    in
    rawPost csrftoken Urls.api_recipients body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.RecipientTable False ])


postKeywordForm : Time.Time -> CSRFToken -> KeywordFormModel -> Maybe Keyword -> Cmd Msg
postKeywordForm now csrftoken model maybeKeyword =
    let
        body =
            [ ( "keyword", Encode.string <| extractField .keyword model.keyword maybeKeyword )
            , ( "description", Encode.string <| extractField .description model.description maybeKeyword )
            , ( "disable_all_replies", Encode.bool <| extractBool .disable_all_replies model.disable_all_replies maybeKeyword )
            , ( "custom_response", Encode.string <| extractField .custom_response model.custom_response maybeKeyword )
            , ( "deactivated_response", Encode.string <| extractField .deactivated_response model.deactivated_response maybeKeyword )
            , ( "too_early_response", Encode.string <| extractField .too_early_response model.too_early_response maybeKeyword )
            , ( "activate_time", encodeDate <| extractDate now .activate_time model.activate_time maybeKeyword )
            , ( "deactivate_time", encodeMaybeDate <| extractMaybeDate .deactivate_time model.deactivate_time maybeKeyword )
            , ( "linked_groups", Encode.list <| List.map Encode.int <| extractPks .linked_groups model.linked_groups maybeKeyword )
            , ( "owners", Encode.list <| List.map Encode.int <| extractPks .owners model.owners maybeKeyword )
            , ( "subscribed_to_digest", Encode.list <| List.map Encode.int <| extractPks .subscribed_to_digest model.subscribers maybeKeyword )
            ]
                |> addPk maybeKeyword
    in
    rawPost csrftoken Urls.api_keywords body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.KeywordTable False ])


postSCForm : CSRFToken -> SiteConfigFormModel -> Cmd Msg
postSCForm csrftoken model =
    let
        body =
            [ ( "site_name", Encode.string model.site_name )
            , ( "sms_char_limit", Encode.int model.sms_char_limit )
            , ( "default_number_prefix", Encode.string model.default_number_prefix )
            , ( "disable_all_replies", Encode.bool model.disable_all_replies )
            , ( "disable_email_login_form", Encode.bool model.disable_email_login_form )
            , ( "office_email", Encode.string model.office_email )
            , ( "auto_add_new_groups", Encode.list (List.map Encode.int model.auto_add_new_groups) )
            , ( "slack_url", Encode.string model.slack_url )
            , ( "sync_elvanto", Encode.bool model.sync_elvanto )
            , ( "not_approved_msg", Encode.string model.not_approved_msg )
            , ( "email_host", Encode.string model.email_host )
            , ( "email_port", encodeMaybe Encode.int model.email_port )
            , ( "email_username", Encode.string model.email_username )
            , ( "email_password", Encode.string model.email_password )
            , ( "email_from", Encode.string model.email_from )
            ]
    in
    rawPost csrftoken Urls.api_site_config body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.Home ])


addPk : Maybe { a | pk : Int } -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addPk maybeRecord body =
    case maybeRecord of
        Nothing ->
            body

        Just rec ->
            ( "pk", Encode.int rec.pk ) :: body


extractDate : Time.Time -> (Keyword -> Date.Date) -> Maybe Date.Date -> Maybe Keyword -> Date.Date
extractDate now fn field maybeKeyword =
    case field of
        Nothing ->
            Maybe.map fn maybeKeyword
                |> Maybe.withDefault (Date.fromTime now)

        Just d ->
            d


extractMaybeDate : (Keyword -> Maybe Date.Date) -> Maybe Date.Date -> Maybe Keyword -> Maybe Date.Date
extractMaybeDate fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing group or default to ""
            case maybeKeyword of
                Nothing ->
                    Nothing

                Just k ->
                    fn k

        Just s ->
            Just s


extractPks : (Keyword -> List Int) -> Maybe (List Int) -> Maybe Keyword -> List Int
extractPks fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing group or default to []
            Maybe.map fn maybeKeyword
                |> Maybe.withDefault []

        Just pks ->
            pks


extractBool : (a -> Bool) -> Maybe Bool -> Maybe a -> Bool
extractBool fn field maybeRec =
    case field of
        Nothing ->
            Maybe.map fn maybeRec
                |> Maybe.withDefault False

        Just b ->
            b
