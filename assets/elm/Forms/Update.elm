module Forms.Update exposing (initDateTimePickers, maybeFetchConfig, update)

import Data exposing (Keyword, Recipient, RecipientGroup, UserProfile)
import Date
import DateTimePicker
import DjangoSend exposing (CSRFToken, rawPost)
import Encode exposing (encodeDate, encodeMaybe, encodeMaybeDate, encodeMaybeDateOnly)
import Forms.Model exposing (FormErrors, FormStatus(Failed, InProgress, Success), decodeFormResp, formDecodeError, noErrors)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (FormMsg(..), Msg(FormMsg))
import Models exposing (Model, Settings, TwilioSettings)
import Navigation as Nav
import Notification as Notif
import Pages as P
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAG
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SendAdhoc as SAF
import Pages.Forms.SendGroup as SGF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UPF
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (page2loc)
import Time
import Urls


update : FormMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        PostCreateAllGroupForm ->
            case model.page of
                P.CreateAllGroup name ->
                    setInProgress model
                        => [ postCreateAllGroupCmd model.settings.csrftoken name ]

                _ ->
                    model => []

        PostDefaultRespForm ->
            case model.page of
                P.DefaultResponsesForm (Just drModel) ->
                    setInProgress model
                        => [ postDefautlRespCmd model.settings.csrftoken drModel ]

                _ ->
                    model => []

        PostGroupForm ->
            case model.page of
                P.GroupForm gfModel maybePk ->
                    setInProgress model
                        => [ postGroupCmd model.settings.csrftoken
                                gfModel
                                (RL.filter (\x -> Just x.pk == maybePk) model.dataStore.groups
                                    |> RL.toList
                                    |> List.head
                                )
                           ]

                _ ->
                    model => []

        PostSendAdhocForm ->
            case model.page of
                P.SendAdhoc saModel ->
                    setInProgress model
                        => [ postSendAdhocCmd model.settings.csrftoken model.settings.userPerms saModel ]

                _ ->
                    model => []

        PostSendGroupForm ->
            case model.page of
                P.SendGroup sgModel ->
                    setInProgress model
                        => [ postSendGroupCmd model.settings.csrftoken model.settings.userPerms sgModel ]

                _ ->
                    model => []

        PostSiteConfigForm ->
            case model.page of
                P.SiteConfigForm (Just scModel) ->
                    setInProgress model
                        => [ postSiteConfigCmd model.settings.csrftoken scModel ]

                _ ->
                    model => []

        PostUserProfileForm ->
            case model.page of
                P.UserProfileForm upfModel pk ->
                    setInProgress model
                        => [ postUserProfileCmd
                                model.settings.csrftoken
                                upfModel
                                (RL.filter (\x -> x.pk == pk) model.dataStore.userprofiles
                                    |> RL.toList
                                    |> List.head
                                )
                           ]

                _ ->
                    model => []

        PostKeywordForm ->
            case model.page of
                P.KeywordForm kfModel maybeK ->
                    setInProgress model
                        => [ postKeywordFormCmd
                                model.settings.csrftoken
                                model.currentTime
                                kfModel
                                (RL.filter (\x -> Just x.keyword == maybeK) model.dataStore.keywords
                                    |> RL.toList
                                    |> List.head
                                )
                           ]

                _ ->
                    model => []

        PostContactForm ->
            case model.page of
                P.ContactForm cfModel maybePk ->
                    setInProgress model
                        => [ postContactFormCmd
                                model.settings.csrftoken
                                cfModel
                                (RL.filter (\x -> Just x.pk == maybePk) model.dataStore.recipients
                                    |> RL.toList
                                    |> List.head
                                )
                           ]

                _ ->
                    model => []

        PostContactImportForm ->
            case model.page of
                P.ContactImport ciModel ->
                    setInProgress model
                        => [ postContactImportCmd
                                model.settings.csrftoken
                                ciModel
                           ]

                _ ->
                    model => []

        ReceiveFormResp okMsg (Ok resp) ->
            case Decode.decodeString decodeFormResp resp.body of
                Ok data ->
                    -- update the form and refetch the site config, to update our settings
                    -- in case we have just edited the site config form
                    ( { model
                        | formStatus = Success
                        , notifications = Notif.addListOfDjangoMessages data.messages model.notifications
                      }
                    , okMsg
                    )
                        |> maybeFetchConfig

                Err err ->
                    ( { model | formStatus = Failed <| formDecodeError err }, [] )

        ReceiveFormResp _ (Err err) ->
            case err of
                Http.BadStatus resp ->
                    case Decode.decodeString decodeFormResp resp.body of
                        Ok data ->
                            ( { model
                                | formStatus = Failed data.errors
                                , notifications = Notif.addListOfDjangoMessages data.messages model.notifications
                              }
                            , []
                            )

                        Err e ->
                            ( { model
                                | formStatus = Failed <| formDecodeError e
                                , notifications = Notif.addRefreshNotif model.notifications
                              }
                            , []
                            )

                _ ->
                    ( { model
                        | formStatus = Failed noErrors
                        , notifications = Notif.addRefreshNotif model.notifications
                      }
                    , []
                    )

        ReceiveSiteConfigFormModel (Ok scModel) ->
            let
                newModel =
                    case model.page of
                        P.SiteConfigForm _ ->
                            { model | page = P.SiteConfigForm <| Just scModel }

                        _ ->
                            model
            in
            { newModel | settings = updateSettings scModel newModel.settings }
                => List.map (Cmd.map FormMsg) (initDateTimePickers model.page)

        ReceiveSiteConfigFormModel (Err _) ->
            ( model, [] )

        ReceiveDefaultResponsesFormModel (Ok drModel) ->
            case model.page of
                P.DefaultResponsesForm _ ->
                    ( { model | page = P.DefaultResponsesForm <| Just drModel }, [] )

                _ ->
                    ( model, [] )

        ReceiveDefaultResponsesFormModel (Err _) ->
            ( model, [] )

        UserProfileFormMsg subMsg ->
            case model.page of
                P.UserProfileForm upfModel pk ->
                    ( { model | page = P.UserProfileForm (UPF.update subMsg upfModel) pk }
                    , []
                    )

                _ ->
                    ( model, [] )

        GroupFormMsg subMsg ->
            case model.page of
                P.GroupForm gfModel maybePk ->
                    ( { model | page = P.GroupForm (GF.update subMsg gfModel) maybePk }
                    , []
                    )

                _ ->
                    ( model, [] )

        ContactFormMsg subMsg ->
            case model.page of
                P.ContactForm cfModel maybePk ->
                    ( { model
                        | page =
                            P.ContactForm (CF.update subMsg cfModel)
                                maybePk
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        KeywordFormMsg subMsg ->
            case model.page of
                P.KeywordForm kfModel maybeK ->
                    ( { model
                        | page =
                            P.KeywordForm (KF.update subMsg kfModel)
                                maybeK
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        SiteConfigFormMsg subMsg ->
            case model.page of
                P.SiteConfigForm _ ->
                    ( { model
                        | page =
                            P.SiteConfigForm <| Just <| SCF.update subMsg
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        DefaultResponsesFormMsg subMsg ->
            case model.page of
                P.DefaultResponsesForm _ ->
                    ( { model
                        | page = P.DefaultResponsesForm <| Just <| DRF.update subMsg
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        SendAdhocMsg subMsg ->
            case model.page of
                P.SendAdhoc saModel ->
                    ( { model | page = P.SendAdhoc <| SAF.update model.settings.twilio subMsg saModel }, [] )

                _ ->
                    ( model, [] )

        SendGroupMsg subMsg ->
            case model.page of
                P.SendGroup sgModel ->
                    ( { model
                        | page =
                            P.SendGroup <|
                                SGF.update
                                    (RL.toList model.dataStore.groups)
                                    subMsg
                                    sgModel
                      }
                    , []
                    )

                _ ->
                    ( model, [] )

        CreateAllGroupMsg subMsg ->
            case model.page of
                P.CreateAllGroup _ ->
                    ( { model | page = P.CreateAllGroup <| CAG.update subMsg }, [] )

                _ ->
                    ( model, [] )

        ContactImportMsg subMsg ->
            case model.page of
                P.ContactImport ciModel ->
                    ( { model | page = P.ContactImport <| CI.update subMsg }, [] )

                _ ->
                    ( model, [] )


updateSettings : SCF.Model -> Settings -> Settings
updateSettings newSCModel settings =
    let
        newTwilio =
            Maybe.map2
                TwilioSettings
                newSCModel.twilio_sending_cost
                newSCModel.twilio_from_num

        newEmailSetup =
            [ isJust newSCModel.email_from
            , isJust newSCModel.email_host
            , isJust newSCModel.email_password
            , isJust newSCModel.email_port
            , isJust newSCModel.email_username
            ]
                |> List.all identity
    in
    { settings
        | smsCharLimit = newSCModel.sms_char_limit
        , defaultNumberPrefix = newSCModel.default_number_prefix
        , twilio = newTwilio
        , isEmailSetup = newEmailSetup
    }


isJust : Maybe a -> Bool
isJust m =
    case m of
        Just _ ->
            True

        Nothing ->
            False


maybeFetchConfig : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchConfig ( model, cmds ) =
    let
        req =
            Http.get Urls.api_site_config SCF.decodeModel
    in
    case model.page of
        P.SiteConfigForm _ ->
            ( model, cmds ++ [ Http.send (FormMsg << ReceiveSiteConfigFormModel) req ] )

        _ ->
            ( model, cmds )


setInProgress : Model -> Model
setInProgress model =
    { model | formStatus = InProgress }


postKeywordFormCmd : CSRFToken -> Time.Time -> KF.Model -> Maybe Keyword -> Cmd Msg
postKeywordFormCmd csrf now model maybeKeyword =
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
    rawPost csrf (Urls.api_keywords Nothing) body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.KeywordTable False ])


postContactFormCmd : CSRFToken -> CF.Model -> Maybe Recipient -> Cmd Msg
postContactFormCmd csrf model maybeContact =
    let
        body =
            [ ( "first_name", Encode.string <| extractField .first_name model.first_name maybeContact )
            , ( "last_name", Encode.string <| extractField .last_name model.last_name maybeContact )
            , ( "number", Encode.string <| extractField (Maybe.withDefault "" << .number) model.number maybeContact )
            , ( "do_not_reply", Encode.bool <| extractBool .do_not_reply model.do_not_reply maybeContact )
            ]
                |> addPk maybeContact
    in
    rawPost csrf (Urls.api_recipients Nothing) body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.RecipientTable False ])


postContactImportCmd : CSRFToken -> String -> Cmd Msg
postContactImportCmd csrf csv =
    let
        body =
            [ ( "csv_data", Encode.string csv ) ]
    in
    rawPost csrf Urls.api_recipients_import_csv body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.Home ])


postCreateAllGroupCmd : CSRFToken -> String -> Cmd Msg
postCreateAllGroupCmd csrf name =
    let
        body =
            [ ( "group_name", Encode.string name ) ]
    in
    rawPost csrf Urls.api_act_create_all_group body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.GroupTable False ])


postDefautlRespCmd : CSRFToken -> DRF.Model -> Cmd Msg
postDefautlRespCmd csrf model =
    let
        body =
            [ ( "keyword_no_match", Encode.string model.keyword_no_match )
            , ( "default_no_keyword_auto_reply", Encode.string model.default_no_keyword_auto_reply )
            , ( "default_no_keyword_not_live", Encode.string model.default_no_keyword_not_live )
            , ( "start_reply", Encode.string model.start_reply )
            , ( "auto_name_request", Encode.string model.auto_name_request )
            , ( "name_update_reply", Encode.string model.name_update_reply )
            , ( "name_failure_reply", Encode.string model.name_failure_reply )
            ]
    in
    rawPost csrf Urls.api_default_responses body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc P.Home ])


postGroupCmd : CSRFToken -> GF.Model -> Maybe RecipientGroup -> Cmd Msg
postGroupCmd csrf model maybeGroup =
    let
        body =
            [ ( "name", Encode.string <| extractField .name model.name maybeGroup )
            , ( "description", Encode.string <| extractField .description model.description maybeGroup )
            ]
                |> addPk maybeGroup
    in
    rawPost csrf (Urls.api_recipient_groups Nothing) body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.GroupTable False ])


postSendAdhocCmd : CSRFToken -> UserProfile -> SAF.Model -> Cmd Msg
postSendAdhocCmd csrf userPerms model =
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
                    case userPerms.user.is_staff of
                        True ->
                            P.ScheduledSmsTable

                        False ->
                            P.OutboundTable
    in
    rawPost csrf Urls.api_act_send_adhoc body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc newLoc ])


postSendGroupCmd : CSRFToken -> UserProfile -> SGF.Model -> Cmd Msg
postSendGroupCmd csrf userPerms model =
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
                    case userPerms.user.is_staff of
                        True ->
                            P.ScheduledSmsTable

                        False ->
                            P.OutboundTable
    in
    rawPost csrf Urls.api_act_send_group body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc newLoc ])


postSiteConfigCmd : CSRFToken -> SCF.Model -> Cmd Msg
postSiteConfigCmd csrf model =
    let
        body =
            [ ( "site_name", Encode.string model.site_name )
            , ( "sms_char_limit", Encode.int model.sms_char_limit )
            , ( "default_number_prefix", Encode.string model.default_number_prefix )
            , ( "disable_all_replies", Encode.bool model.disable_all_replies )
            , ( "disable_email_login_form", Encode.bool model.disable_email_login_form )
            , ( "office_email", Encode.string model.office_email )
            , ( "auto_add_new_groups", Encode.list (List.map Encode.int model.auto_add_new_groups) )
            , ( "sms_expiration_date", encodeMaybeDateOnly model.sms_expiration_date )
            , ( "sms_rolling_expiration_days", encodeMaybe Encode.int model.sms_rolling_expiration_days )
            , ( "slack_url", Encode.string model.slack_url )
            , ( "sync_elvanto", Encode.bool model.sync_elvanto )
            , ( "not_approved_msg", Encode.string model.not_approved_msg )
            , ( "email_host", encodeMaybe Encode.string model.email_host )
            , ( "email_port", encodeMaybe Encode.int model.email_port )
            , ( "email_username", encodeMaybe Encode.string model.email_username )
            , ( "email_password", encodeMaybe Encode.string model.email_password )
            , ( "email_from", encodeMaybe Encode.string model.email_from )
            , ( "twilio_from_num", encodeMaybe Encode.string model.twilio_from_num )
            , ( "twilio_sending_cost", encodeMaybe Encode.float model.twilio_sending_cost )
            , ( "twilio_auth_token", encodeMaybe Encode.string model.twilio_auth_token )
            , ( "twilio_account_sid", encodeMaybe Encode.string model.twilio_account_sid )
            ]
    in
    rawPost csrf Urls.api_site_config body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.Home ])


postUserProfileCmd : CSRFToken -> UPF.Model -> Maybe UserProfile -> Cmd Msg
postUserProfileCmd csrf model maybeProfile =
    let
        body =
            [ ( "approved", Encode.bool <| extractBool .approved model.approved maybeProfile )
            , ( "message_cost_limit", Encode.float <| extractFloat .message_cost_limit model.message_cost_limit maybeProfile )
            , ( "can_see_groups", Encode.bool <| extractBool .can_see_groups model.can_see_groups maybeProfile )
            , ( "can_see_contact_names", Encode.bool <| extractBool .can_see_contact_names model.can_see_contact_names maybeProfile )
            , ( "can_see_keywords", Encode.bool <| extractBool .can_see_keywords model.can_see_keywords maybeProfile )
            , ( "can_see_outgoing", Encode.bool <| extractBool .can_see_outgoing model.can_see_outgoing maybeProfile )
            , ( "can_see_incoming", Encode.bool <| extractBool .can_see_incoming model.can_see_incoming maybeProfile )
            , ( "can_send_sms", Encode.bool <| extractBool .can_send_sms model.can_send_sms maybeProfile )
            , ( "can_see_contact_nums", Encode.bool <| extractBool .can_see_contact_nums model.can_see_contact_nums maybeProfile )
            , ( "can_import", Encode.bool <| extractBool .can_import model.can_import maybeProfile )
            , ( "can_archive", Encode.bool <| extractBool .can_archive model.can_archive maybeProfile )
            ]
                |> addPk maybeProfile
    in
    case maybeProfile of
        Nothing ->
            Cmd.none

        Just _ ->
            rawPost csrf Urls.api_user_profiles body
                |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.UserProfileTable ])


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
            -- never edited the field, use existing or default to ""
            Maybe.andThen fn maybeKeyword

        Just s ->
            Just s


extractPks : (Keyword -> List Int) -> Maybe (List Int) -> Maybe Keyword -> List Int
extractPks fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to []
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


extractField : (a -> String) -> Maybe String -> Maybe a -> String
extractField fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to ""
            Maybe.map fn maybeRec
                |> Maybe.withDefault ""

        Just s ->
            s


extractFloat : (a -> Float) -> Maybe Float -> Maybe a -> Float
extractFloat fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to 0
            Maybe.map fn maybeRec
                |> Maybe.withDefault 0

        Just s ->
            s



-- Date Pickers


initDateTimePickers : P.Page -> List (Cmd FormMsg)
initDateTimePickers page =
    initDateTimePickersHelp page


initDateTimePickersHelp : P.Page -> List (Cmd FormMsg)
initDateTimePickersHelp page =
    case page of
        P.KeywordForm model _ ->
            [ DateTimePicker.initialCmd initActTime model.datePickerActState
            , DateTimePicker.initialCmd initDeactTime model.datePickerDeactState
            ]

        P.SendAdhoc model ->
            [ DateTimePicker.initialCmd initSendAdhocDate model.datePickerState ]

        P.SendGroup model ->
            [ DateTimePicker.initialCmd initSendGroupDate model.datePickerState ]

        P.SiteConfigForm maybeModel ->
            case maybeModel of
                Just model ->
                    [ DateTimePicker.initialCmd (initSmsExpireDate model) model.datePickerSmsExpiredState ]

                Nothing ->
                    []

        _ ->
            []


initActTime : DateTimePicker.State -> Maybe Date.Date -> FormMsg
initActTime state maybeDate =
    KeywordFormMsg <| KF.UpdateActivateTime state maybeDate


initDeactTime : DateTimePicker.State -> Maybe Date.Date -> FormMsg
initDeactTime state maybeDate =
    KeywordFormMsg <| KF.UpdateDeactivateTime state maybeDate


initSendAdhocDate : DateTimePicker.State -> Maybe Date.Date -> FormMsg
initSendAdhocDate state maybeDate =
    SendAdhocMsg <| SAF.UpdateDate state maybeDate


initSendGroupDate : DateTimePicker.State -> Maybe Date.Date -> FormMsg
initSendGroupDate state maybeDate =
    SendGroupMsg <| SGF.UpdateSGDate state maybeDate


initSmsExpireDate : SCF.Model -> DateTimePicker.State -> Maybe Date.Date -> FormMsg
initSmsExpireDate model datePickerSmsExpiredState maybeDate =
    SiteConfigFormMsg <| SCF.UpdateSmsExpiredDate model datePickerSmsExpiredState model.sms_expiration_date
