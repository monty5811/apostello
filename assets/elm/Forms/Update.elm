module Forms.Update exposing (update)

import Forms.DatePickers exposing (initDateTimePickers)
import Forms.Model exposing (FormErrors, FormStatus(Failed, InProgress, Success), decodeFormResp, formDecodeError, noErrors)
import Http
import Json.Decode as Decode
import Messages exposing (FormMsg(..), Msg)
import Models exposing (Model, Settings)
import Pages as P
import Pages.Forms.Contact.Update as CF
import Pages.Forms.ContactImport.Update as CI
import Pages.Forms.CreateAllGroup.Update as CAG
import Pages.Forms.DefaultResponses.Update as DRF
import Pages.Forms.Group.Update as GF
import Pages.Forms.Keyword.Update as KF
import Pages.Forms.SendAdhoc.Update as SA
import Pages.Forms.SendGroup.Update as SG
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)
import Pages.Forms.SiteConfig.Update as SCF
import Pages.Forms.UserProfile.Update as UPF
import Pages.Fragments.Notification as Notif
import RemoteList as RL


update : FormMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        PostForm cmd ->
            ( { model | formStatus = InProgress }, [ cmd ] )

        ReceiveFormResp okMsg (Ok resp) ->
            case Decode.decodeString decodeFormResp resp.body of
                Ok data ->
                    ( { model
                        | formStatus = Success
                        , notifications = Notif.addListOfDjangoMessagesNoDestroy data.messages model.notifications
                      }
                    , okMsg
                    )

                Err err ->
                    ( { model | formStatus = Failed <| formDecodeError err }, [] )

        ReceiveFormResp _ (Err err) ->
            case err of
                Http.BadStatus resp ->
                    case Decode.decodeString decodeFormResp resp.body of
                        Ok data ->
                            ( { model
                                | formStatus = Failed data.errors
                                , notifications = Notif.addListOfDjangoMessagesNoDestroy data.messages model.notifications
                              }
                            , []
                            )

                        Err e ->
                            ( { model
                                | formStatus = Failed <| formDecodeError e
                                , notifications = Notif.addListOfDjangoMessagesNoDestroy [ Notif.refreshNotifMessage ] model.notifications
                              }
                            , []
                            )

                _ ->
                    ( { model
                        | formStatus = Failed noErrors
                        , notifications = Notif.addListOfDjangoMessagesNoDestroy [ Notif.refreshNotifMessage ] model.notifications
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
            ( { newModel | settings = updateSettings scModel newModel.settings }, [] )
                |> initDateTimePickers

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
                    ( { model | page = P.SendAdhoc <| SA.update model.settings.twilioSendingCost subMsg saModel }, [] )

                _ ->
                    ( model, [] )

        SendGroupMsg subMsg ->
            case model.page of
                P.SendGroup sgModel ->
                    ( { model
                        | page =
                            P.SendGroup <|
                                SG.update
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
                    ( { model | page = P.ContactImport <| CI.update subMsg ciModel }, [] )

                _ ->
                    ( model, [] )


updateSettings : SiteConfigFormModel -> Settings -> Settings
updateSettings newSCModel settings =
    { settings
        | smsCharLimit = newSCModel.sms_char_limit
        , defaultNumberPrefix = newSCModel.default_number_prefix
    }
