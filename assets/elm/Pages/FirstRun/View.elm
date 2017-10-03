module Pages.FirstRun.View exposing (view)

import Html exposing (Html, button, div, h3, input, label, p, pre, text)
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit)
import Messages exposing (Msg(FirstRunMsg))
import Pages.FirstRun.Messages exposing (FirstRunMsg(..))
import Pages.FirstRun.Model exposing (FirstRunFormStatus(Failed, InProgress, NoAction, Success), FirstRunModel)


view : FirstRunModel -> Html Msg
view model =
    div []
        [ testEmailView model
        , testSmsView model
        , createAdminView model
        ]


testEmailView : FirstRunModel -> Html Msg
testEmailView model =
    div [ A.id "sent_test_email" ]
        [ div [ A.class "segment" ]
            [ h3 [] [ text "Send Test Email" ]
            , Html.form [ onSubmit <| FirstRunMsg SendTestEmail ]
                [ formMsg model.testEmailFormStatus emailSuccessMsg
                , div [ A.class "input-field" ]
                    [ label [] [ text "Email Address" ]
                    , input
                        [ A.type_ "email"
                        , A.name "email-to"
                        , A.placeholder "test@example.com"
                        , A.id "email_to"
                        , onInput (FirstRunMsg << UpdateTestEmailToField)
                        ]
                        []
                    ]
                , div [ A.class "input-field" ]
                    [ label [] [ text "Email Body" ]
                    , input
                        [ A.type_ "text"
                        , A.name "email-body"
                        , A.placeholder "This is a test"
                        , A.id "email_body"
                        , onInput (FirstRunMsg << UpdateTestEmailBodyField)
                        ]
                        []
                    ]
                , button [ A.class "button", A.id "email_send_button" ] [ text "Send" ]
                ]
            ]
        ]


testSmsView : FirstRunModel -> Html Msg
testSmsView model =
    div [ A.id "sent_test_sms" ]
        [ div [ A.class "segment" ]
            [ h3 [] [ text "Send Test SMS" ]
            , Html.form [ onSubmit <| FirstRunMsg SendTestSms ]
                [ formMsg model.testSmsFormStatus smsSuccessMsg
                , div [ A.class "input-field" ]
                    [ label [] [ text "Phone Number" ]
                    , input
                        [ A.type_ "text"
                        , A.name "sms-to"
                        , A.placeholder "+447095320967"
                        , A.id "sms_to"
                        , onInput (FirstRunMsg << UpdateTestSmsToField)
                        ]
                        []
                    ]
                , div [ A.class "input-field" ]
                    [ label [] [ text "SMS Body" ]
                    , input
                        [ A.type_ "text"
                        , A.name "sms-body"
                        , A.placeholder "This is a test"
                        , A.id "sms_body"
                        , onInput (FirstRunMsg << UpdateTestSmsBodyField)
                        ]
                        []
                    ]
                , button [ A.class "button", A.id "sms_send_button" ] [ text "Send" ]
                ]
            ]
        ]


createAdminView : FirstRunModel -> Html Msg
createAdminView model =
    div [ A.id "create_admin_user" ]
        [ div [ A.class "segment" ]
            [ h3 [] [ text "Create Admin User" ]
            , Html.form [ onSubmit <| FirstRunMsg CreateAdminUser ]
                [ formMsg model.adminFormStatus adminSuccessMsg
                , div [ A.class "input-field" ]
                    [ label [] [ text "Admin Email" ]
                    , input
                        [ A.type_ "email"
                        , A.name "email"
                        , A.placeholder "you@example.com"
                        , A.id "admin_email"
                        , onInput (FirstRunMsg << UpdateAdminEmailField)
                        ]
                        []
                    ]
                , div [ A.class "two-column" ]
                    [ div [ A.class "input-field" ]
                        [ label [] [ text "Password" ]
                        , input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass1"
                            , onInput (FirstRunMsg << UpdateAdminPass1Field)
                            ]
                            []
                        ]
                    , div [ A.class "input-field" ]
                        [ label [] [ text "Password Again" ]
                        , input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass2"
                            , onInput (FirstRunMsg << UpdateAdminPass2Field)
                            ]
                            []
                        ]
                    ]
                , button [ A.class "button", A.id "create_admin_button" ]
                    [ text "Create" ]
                ]
            ]
        ]


formMsg : FirstRunFormStatus -> Html Msg -> Html Msg
formMsg status successDiv =
    case status of
        NoAction ->
            text ""

        InProgress ->
            text ""

        Success ->
            successDiv

        Failed e ->
            div [ A.class "alert alert-danger" ]
                [ Html.h4 [] [ text "Uh oh, something went wrong!" ]
                , p [] [ text "Check your settings and try again." ]
                , p [] [ text "Error:" ]
                , pre [] [ text e ]
                ]


adminSuccessMsg : Html Msg
adminSuccessMsg =
    div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ text "Admin User Created" ]
        , p [] [ text "Refresh this page and you will be able to login" ]
        ]


emailSuccessMsg : Html Msg
emailSuccessMsg =
    div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ text "Email sent!" ]
        , p [] [ text "Check your inbox to confirm!" ]
        ]


smsSuccessMsg : Html Msg
smsSuccessMsg =
    div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ text "SMS Sending!" ]
        , p [] [ text "Check your phone to confirm!" ]
        ]
