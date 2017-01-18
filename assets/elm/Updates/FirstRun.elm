module Updates.FirstRun exposing (update)

import Decoders exposing (..)
import DjangoSend exposing (post)
import Helpers exposing (encodeBody)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : FirstRunMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( frModel, cmd ) =
            updateFRModel msg model.csrftoken model.firstRun
    in
        ( { model | firstRun = frModel }, cmd )


updateFRModel : FirstRunMsg -> CSRFToken -> FirstRunModel -> ( FirstRunModel, Cmd Msg )
updateFRModel msg csrftoken model =
    case msg of
        UpdateAdminEmailField text ->
            ( { model | adminEmail = text }, Cmd.none )

        UpdateAdminPass1Field text ->
            ( { model | adminPass1 = text }, Cmd.none )

        UpdateAdminPass2Field text ->
            ( { model | adminPass2 = text }, Cmd.none )

        CreateAdminUser ->
            if (model.adminPass1 == model.adminPass2) then
                ( { model | adminFormStatus = InProgress }, createAdminUser csrftoken model )
            else
                ( { model | adminFormStatus = Failed "Passwords do not match" }, Cmd.none )

        ReceiveCreateAdminUser (Ok r) ->
            ( { model | adminFormStatus = Success }, Cmd.none )

        ReceiveCreateAdminUser (Err e) ->
            ( { model | adminFormStatus = Failed (pullOutError e) }, Cmd.none )

        UpdateTestEmailToField text ->
            ( { model | testEmailTo = text }, Cmd.none )

        UpdateTestEmailBodyField text ->
            ( { model | testEmailBody = text }, Cmd.none )

        SendTestEmail ->
            ( { model | testEmailFormStatus = InProgress }, sendTestEmail csrftoken model )

        ReceiveSendTestEmail (Ok r) ->
            ( { model | testEmailFormStatus = Success }, Cmd.none )

        ReceiveSendTestEmail (Err e) ->
            ( { model | testEmailFormStatus = Failed (pullOutError e) }, Cmd.none )

        UpdateTestSmsToField text ->
            ( { model | testSmsTo = text }, Cmd.none )

        UpdateTestSmsBodyField text ->
            ( { model | testSmsBody = text }, Cmd.none )

        SendTestSms ->
            ( { model | testSmsFormStatus = InProgress }, sendTestSms csrftoken model )

        ReceiveSendTestSms (Ok r) ->
            ( { model | testSmsFormStatus = Success }, Cmd.none )

        ReceiveSendTestSms (Err e) ->
            ( { model | testSmsFormStatus = Failed (pullOutError e) }, Cmd.none )


pullOutError : Http.Error -> String
pullOutError e =
    case e of
        Http.BadUrl _ ->
            "Bad url"

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus r ->
            r.body
                |> Decode.decodeString decodeFirstRunResp
                |> Result.withDefault { status = "", error = r.body }
                |> .error

        Http.BadPayload msg _ ->
            msg


createAdminUser : CSRFToken -> FirstRunModel -> Cmd Msg
createAdminUser csrftoken model =
    let
        body =
            encodeBody
                [ ( "email_", Encode.string model.adminEmail )
                , ( "pass_", Encode.string model.adminPass1 )
                ]
    in
        post "/config/create_admin_user/" body csrftoken decodeFirstRunResp
            |> Http.send (FirstRunMsg << ReceiveCreateAdminUser)


sendTestSms : CSRFToken -> FirstRunModel -> Cmd Msg
sendTestSms csrftoken model =
    let
        body =
            encodeBody
                [ ( "to_", Encode.string model.testSmsTo )
                , ( "body_", Encode.string model.testSmsBody )
                ]
    in
        post "/config/send_test_sms/" body csrftoken decodeFirstRunResp
            |> Http.send (FirstRunMsg << ReceiveSendTestSms)


sendTestEmail : CSRFToken -> FirstRunModel -> Cmd Msg
sendTestEmail csrftoken model =
    let
        body =
            encodeBody
                [ ( "to_", Encode.string model.testEmailTo )
                , ( "body_", Encode.string model.testEmailBody )
                ]
    in
        post "/config/send_test_email/" body csrftoken decodeFirstRunResp
            |> Http.send (FirstRunMsg << ReceiveSendTestEmail)
