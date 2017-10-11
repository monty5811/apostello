module Pages.FirstRun exposing (Model, Msg, decodeFirstRunResp, initialModel, update, view)

import DjangoSend exposing (CSRFToken, post)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode


type alias FirstRunResp =
    { status : String
    , error : String
    }


type FirstRunFormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String


decodeFirstRunResp : Decode.Decoder FirstRunResp
decodeFirstRunResp =
    decode FirstRunResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


type alias Model =
    { adminEmail : String
    , adminPass1 : String
    , adminPass2 : String
    , adminFormStatus : FirstRunFormStatus
    , testEmailTo : String
    , testEmailBody : String
    , testEmailFormStatus : FirstRunFormStatus
    , testSmsTo : String
    , testSmsBody : String
    , testSmsFormStatus : FirstRunFormStatus
    }


initialModel : Model
initialModel =
    { adminEmail = ""
    , adminPass1 = ""
    , adminPass2 = ""
    , adminFormStatus = NoAction
    , testEmailTo = ""
    , testEmailBody = ""
    , testEmailFormStatus = NoAction
    , testSmsTo = ""
    , testSmsBody = ""
    , testSmsFormStatus = NoAction
    }



-- Update


type Msg
    = UpdateAdminEmailField String
    | UpdateAdminPass1Field String
    | UpdateAdminPass2Field String
    | UpdateTestEmailToField String
    | UpdateTestEmailBodyField String
    | UpdateTestSmsToField String
    | UpdateTestSmsBodyField String
    | SendTestEmail
    | SendTestSms
    | CreateAdminUser
    | ReceiveCreateAdminUser (Result Http.Error FirstRunResp)
    | ReceiveSendTestSms (Result Http.Error FirstRunResp)
    | ReceiveSendTestEmail (Result Http.Error FirstRunResp)


update : CSRFToken -> Msg -> Model -> ( Model, List (Cmd Msg) )
update csrf msg model =
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


createAdminUser : CSRFToken -> Model -> Cmd Msg
createAdminUser csrf model =
    let
        body =
            [ ( "email_", Encode.string model.adminEmail )
            , ( "pass_", Encode.string model.adminPass1 )
            ]
    in
    post csrf "/config/create_admin_user/" body decodeFirstRunResp
        |> Http.send ReceiveCreateAdminUser


sendTestSms : CSRFToken -> Model -> Cmd Msg
sendTestSms csrf model =
    let
        body =
            [ ( "to_", Encode.string model.testSmsTo )
            , ( "body_", Encode.string model.testSmsBody )
            ]
    in
    post csrf "/config/send_test_sms/" body decodeFirstRunResp
        |> Http.send ReceiveSendTestSms


sendTestEmail : CSRFToken -> Model -> Cmd Msg
sendTestEmail csrf model =
    let
        body =
            [ ( "to_", Encode.string model.testEmailTo )
            , ( "body_", Encode.string model.testEmailBody )
            ]
    in
    post csrf "/config/send_test_email/" body decodeFirstRunResp
        |> Http.send ReceiveSendTestEmail



-- View


view : Model -> Html Msg
view model =
    Html.div []
        [ testEmailView model
        , testSmsView model
        , createAdminView model
        ]


testEmailView : Model -> Html Msg
testEmailView model =
    Html.div [ A.id "sent_test_email" ]
        [ Html.div [ A.class "segment" ]
            [ Html.h3 [] [ Html.text "Send Test Email" ]
            , Html.form [ onSubmit SendTestEmail ]
                [ formMsg model.testEmailFormStatus emailSuccessMsg
                , Html.div [ A.class "input-field" ]
                    [ Html.label [] [ Html.text "Email Address" ]
                    , Html.input
                        [ A.type_ "email"
                        , A.name "email-to"
                        , A.placeholder "test@example.com"
                        , A.id "email_to"
                        , onInput UpdateTestEmailToField
                        ]
                        []
                    ]
                , Html.div [ A.class "input-field" ]
                    [ Html.label [] [ Html.text "Email Body" ]
                    , Html.input
                        [ A.type_ "text"
                        , A.name "email-body"
                        , A.placeholder "This is a test"
                        , A.id "email_body"
                        , onInput UpdateTestEmailBodyField
                        ]
                        []
                    ]
                , Html.button [ A.class "button", A.id "email_send_button" ] [ Html.text "Send" ]
                ]
            ]
        ]


testSmsView : Model -> Html Msg
testSmsView model =
    Html.div [ A.id "sent_test_sms" ]
        [ Html.div [ A.class "segment" ]
            [ Html.h3 [] [ Html.text "Send Test SMS" ]
            , Html.form [ onSubmit SendTestSms ]
                [ formMsg model.testSmsFormStatus smsSuccessMsg
                , Html.div [ A.class "input-field" ]
                    [ Html.label [] [ Html.text "Phone Number" ]
                    , Html.input
                        [ A.type_ "text"
                        , A.name "sms-to"
                        , A.placeholder "+447095320967"
                        , A.id "sms_to"
                        , onInput UpdateTestSmsToField
                        ]
                        []
                    ]
                , Html.div [ A.class "input-field" ]
                    [ Html.label [] [ Html.text "SMS Body" ]
                    , Html.input
                        [ A.type_ "text"
                        , A.name "sms-body"
                        , A.placeholder "This is a test"
                        , A.id "sms_body"
                        , onInput UpdateTestSmsBodyField
                        ]
                        []
                    ]
                , Html.button [ A.class "button", A.id "sms_send_button" ] [ Html.text "Send" ]
                ]
            ]
        ]


createAdminView : Model -> Html Msg
createAdminView model =
    Html.div [ A.id "create_admin_user" ]
        [ Html.div [ A.class "segment" ]
            [ Html.h3 [] [ Html.text "Create Admin User" ]
            , Html.form [ onSubmit CreateAdminUser ]
                [ formMsg model.adminFormStatus adminSuccessMsg
                , Html.div [ A.class "input-field" ]
                    [ Html.label [] [ Html.text "Admin Email" ]
                    , Html.input
                        [ A.type_ "email"
                        , A.name "email"
                        , A.placeholder "you@example.com"
                        , A.id "admin_email"
                        , onInput UpdateAdminEmailField
                        ]
                        []
                    ]
                , Html.div [ A.class "two-column" ]
                    [ Html.div [ A.class "input-field" ]
                        [ Html.label [] [ Html.text "Password" ]
                        , Html.input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass1"
                            , onInput UpdateAdminPass1Field
                            ]
                            []
                        ]
                    , Html.div [ A.class "input-field" ]
                        [ Html.label [] [ Html.text "Password Again" ]
                        , Html.input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass2"
                            , onInput UpdateAdminPass2Field
                            ]
                            []
                        ]
                    ]
                , Html.button [ A.class "button", A.id "create_admin_button" ]
                    [ Html.text "Create" ]
                ]
            ]
        ]


formMsg : FirstRunFormStatus -> Html Msg -> Html Msg
formMsg status successDiv =
    case status of
        NoAction ->
            Html.text ""

        InProgress ->
            Html.text ""

        Success ->
            successDiv

        Failed e ->
            Html.div [ A.class "alert alert-danger" ]
                [ Html.h4 [] [ Html.text "Uh oh, something went wrong!" ]
                , Html.p [] [ Html.text "Check your settings and try again." ]
                , Html.p [] [ Html.text "Error:" ]
                , Html.pre [] [ Html.text e ]
                ]


adminSuccessMsg : Html Msg
adminSuccessMsg =
    Html.div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ Html.text "Admin User Created" ]
        , Html.p [] [ Html.text "Refresh this page and you will be able to login" ]
        ]


emailSuccessMsg : Html Msg
emailSuccessMsg =
    Html.div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ Html.text "Email sent!" ]
        , Html.p [] [ Html.text "Check your inbox to confirm!" ]
        ]


smsSuccessMsg : Html Msg
smsSuccessMsg =
    Html.div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ Html.text "SMS Sending!" ]
        , Html.p [] [ Html.text "Check your phone to confirm!" ]
        ]
