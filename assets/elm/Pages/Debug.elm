module Pages.Debug exposing (Model, Msg, decodeDebuggerResp, initialModel, update, view)

import Css
import DjangoSend exposing (CSRFToken, post)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode


type alias DebuggerResp =
    { status : String
    , error : String
    }


type DebuggerFormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String


decodeDebuggerResp : Decode.Decoder DebuggerResp
decodeDebuggerResp =
    decode DebuggerResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


type alias Model =
    { testEmailTo : String
    , testEmailBody : String
    , testEmailFormStatus : DebuggerFormStatus
    , testSmsTo : String
    , testSmsBody : String
    , testSmsFormStatus : DebuggerFormStatus
    }


initialModel : Model
initialModel =
    { testEmailTo = ""
    , testEmailBody = ""
    , testEmailFormStatus = NoAction
    , testSmsTo = ""
    , testSmsBody = ""
    , testSmsFormStatus = NoAction
    }



-- Update


type Msg
    = UpdateTestEmailToField String
    | UpdateTestEmailBodyField String
    | UpdateTestSmsToField String
    | UpdateTestSmsBodyField String
    | SendTestEmail
    | SendTestSms
    | ReceiveSendTestSms (Result Http.Error DebuggerResp)
    | ReceiveSendTestEmail (Result Http.Error DebuggerResp)


update : CSRFToken -> Msg -> Model -> ( Model, List (Cmd Msg) )
update csrf msg model =
    case msg of
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
                |> Decode.decodeString decodeDebuggerResp
                |> Result.withDefault { status = "", error = r.body }
                |> .error

        Http.BadPayload msg _ ->
            msg


sendTestSms : CSRFToken -> Model -> Cmd Msg
sendTestSms csrf model =
    let
        body =
            [ ( "to_", Encode.string model.testSmsTo )
            , ( "body_", Encode.string model.testSmsBody )
            ]
    in
    post csrf "/config/send_test_sms/" body decodeDebuggerResp
        |> Http.send ReceiveSendTestSms


sendTestEmail : CSRFToken -> Model -> Cmd Msg
sendTestEmail csrf model =
    let
        body =
            [ ( "to_", Encode.string model.testEmailTo )
            , ( "body_", Encode.string model.testEmailBody )
            ]
    in
    post csrf "/config/send_test_email/" body decodeDebuggerResp
        |> Http.send ReceiveSendTestEmail



-- View


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.p [ Css.mb_4 ] [ Html.text "Use these forms to test your Email and Twilio settings." ]
        , testEmailView model
        , testSmsView model
        ]


testEmailView : Model -> Html Msg
testEmailView model =
    Html.div [ A.id "sent_test_email" ]
        [ Html.div []
            [ Html.h3 [] [ Html.text "Send Test Email" ]
            , Html.form [ onSubmit SendTestEmail ]
                [ formMsg model.testEmailFormStatus emailSuccessMsg
                , Html.div []
                    [ Html.label [ Css.label ] [ Html.text "Email Address" ]
                    , Html.input
                        [ A.type_ "email"
                        , A.name "email-to"
                        , A.placeholder "test@example.com"
                        , A.id "email_to"
                        , onInput UpdateTestEmailToField
                        , Css.formInput
                        ]
                        []
                    ]
                , Html.div []
                    [ Html.label [ Css.label ] [ Html.text "Email Body" ]
                    , Html.input
                        [ A.type_ "text"
                        , A.name "email-body"
                        , A.placeholder "This is a test"
                        , A.id "email_body"
                        , onInput UpdateTestEmailBodyField
                        , Css.formInput
                        ]
                        []
                    ]
                , Html.button
                    [ A.id "email_send_button"
                    , Css.btn
                    , Css.btn_purple
                    , Css.my_4
                    ]
                    [ Html.text "Send" ]
                ]
            ]
        ]


testSmsView : Model -> Html Msg
testSmsView model =
    Html.div [ A.id "sent_test_sms" ]
        [ Html.div []
            [ Html.h3 [] [ Html.text "Send Test SMS" ]
            , Html.form [ onSubmit SendTestSms ]
                [ formMsg model.testSmsFormStatus smsSuccessMsg
                , Html.div [ Css.label ]
                    [ Html.label [] [ Html.text "Phone Number" ]
                    , Html.input
                        [ A.type_ "text"
                        , A.name "sms-to"
                        , A.placeholder "+447095320967"
                        , A.id "sms_to"
                        , onInput UpdateTestSmsToField
                        , Css.formInput
                        ]
                        []
                    ]
                , Html.div []
                    [ Html.label [ Css.label ] [ Html.text "SMS Body" ]
                    , Html.input
                        [ A.type_ "text"
                        , A.name "sms-body"
                        , A.placeholder "This is a test"
                        , A.id "sms_body"
                        , onInput UpdateTestSmsBodyField
                        , Css.formInput
                        ]
                        []
                    ]
                , Html.button
                    [ A.id "sms_send_button"
                    , Css.btn
                    , Css.btn_purple
                    , Css.my_4
                    ]
                    [ Html.text "Send" ]
                ]
            ]
        ]


formMsg : DebuggerFormStatus -> Html Msg -> Html Msg
formMsg status successDiv =
    case status of
        NoAction ->
            Html.text ""

        InProgress ->
            Html.text ""

        Success ->
            successDiv

        Failed e ->
            Html.div []
                [ Html.h4 [] [ Html.text "Uh oh, something went wrong!" ]
                , Html.p [] [ Html.text "Check your settings and try again." ]
                , Html.p [] [ Html.text "Error:" ]
                , Html.pre [] [ Html.text e ]
                ]


emailSuccessMsg : Html Msg
emailSuccessMsg =
    Html.div []
        [ Html.h4 [] [ Html.text "Email sent!" ]
        , Html.p [] [ Html.text "Check your inbox to confirm!" ]
        ]


smsSuccessMsg : Html Msg
smsSuccessMsg =
    Html.div []
        [ Html.h4 [] [ Html.text "SMS Sending!" ]
        , Html.p [] [ Html.text "Check your phone to confirm!" ]
        ]
