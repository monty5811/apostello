module Pages.FirstRun.Update exposing (update)

import DjangoSend exposing (CSRFToken, post)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(FirstRunMsg))
import Models exposing (Model)
import Pages exposing (Page)
import Pages.FirstRun.Messages exposing (FirstRunMsg(..))
import Pages.FirstRun.Model exposing (FirstRunFormStatus(..), FirstRunModel, decodeFirstRunResp)


update : FirstRunMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case model.page of
        Pages.FirstRun oldModel ->
            let
                ( newFrModel, cmds ) =
                    updateFRModel model.settings.csrftoken msg oldModel
            in
            ( { model | page = Pages.FirstRun newFrModel }, cmds )

        _ ->
            ( model, [] )


updateFRModel : CSRFToken -> FirstRunMsg -> FirstRunModel -> ( FirstRunModel, List (Cmd Msg) )
updateFRModel csrf msg model =
    case msg of
        UpdateAdminEmailField text ->
            ( { model | adminEmail = text }, [] )

        UpdateAdminPass1Field text ->
            ( { model | adminPass1 = text }, [] )

        UpdateAdminPass2Field text ->
            ( { model | adminPass2 = text }, [] )

        CreateAdminUser ->
            case model.adminPass1 == model.adminPass2 of
                True ->
                    ( { model | adminFormStatus = InProgress }, [ createAdminUser csrf model ] )

                False ->
                    ( { model | adminFormStatus = Failed "Passwords do not match" }, [] )

        ReceiveCreateAdminUser (Ok _) ->
            ( { model | adminFormStatus = Success }, [] )

        ReceiveCreateAdminUser (Err e) ->
            ( { model | adminFormStatus = Failed (pullOutError e) }, [] )

        UpdateTestEmailToField text ->
            ( { model | testEmailTo = text }, [] )

        UpdateTestEmailBodyField text ->
            ( { model | testEmailBody = text }, [] )

        SendTestEmail ->
            ( { model | testEmailFormStatus = InProgress }, [ sendTestEmail csrf model ] )

        ReceiveSendTestEmail (Ok _) ->
            ( { model | testEmailFormStatus = Success }, [] )

        ReceiveSendTestEmail (Err e) ->
            ( { model | testEmailFormStatus = Failed (pullOutError e) }, [] )

        UpdateTestSmsToField text ->
            ( { model | testSmsTo = text }, [] )

        UpdateTestSmsBodyField text ->
            ( { model | testSmsBody = text }, [] )

        SendTestSms ->
            ( { model | testSmsFormStatus = InProgress }, [ sendTestSms csrf model ] )

        ReceiveSendTestSms (Ok _) ->
            ( { model | testSmsFormStatus = Success }, [] )

        ReceiveSendTestSms (Err e) ->
            ( { model | testSmsFormStatus = Failed (pullOutError e) }, [] )


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
createAdminUser csrf model =
    let
        body =
            [ ( "email_", Encode.string model.adminEmail )
            , ( "pass_", Encode.string model.adminPass1 )
            ]
    in
    post csrf "/config/create_admin_user/" body decodeFirstRunResp
        |> Http.send (FirstRunMsg << ReceiveCreateAdminUser)


sendTestSms : CSRFToken -> FirstRunModel -> Cmd Msg
sendTestSms csrf model =
    let
        body =
            [ ( "to_", Encode.string model.testSmsTo )
            , ( "body_", Encode.string model.testSmsBody )
            ]
    in
    post csrf "/config/send_test_sms/" body decodeFirstRunResp
        |> Http.send (FirstRunMsg << ReceiveSendTestSms)


sendTestEmail : CSRFToken -> FirstRunModel -> Cmd Msg
sendTestEmail csrf model =
    let
        body =
            [ ( "to_", Encode.string model.testEmailTo )
            , ( "body_", Encode.string model.testEmailBody )
            ]
    in
    post csrf "/config/send_test_email/" body decodeFirstRunResp
        |> Http.send (FirstRunMsg << ReceiveSendTestEmail)
