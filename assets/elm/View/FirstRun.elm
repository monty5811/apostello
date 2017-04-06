module View.FirstRun exposing (view)

import Html exposing (Html, text, p, div, pre, button, input, label, h3, br)
import Html.Attributes as A
import Html.Events exposing (onInput)
import Messages exposing (Msg(FirstRunMsg), FirstRunMsg(..))
import Models.FirstRun exposing (FirstRunModel)
import Models.FormStatus exposing (FormStatus(..))
import View.Helpers exposing (..)


view : FirstRunModel -> Html Msg
view model =
    div []
        [ testEmailView model
        , br [] []
        , testSmsView model
        , br [] []
        , createAdminView model
        , br [] []
        ]


testEmailView : FirstRunModel -> Html Msg
testEmailView model =
    div [ A.id "sent_test_email" ]
        [ div [ A.class "ui raised segment" ]
            [ h3 [] [ text "Send Test Email" ]
            , Html.form [ A.class (formClass model.testEmailFormStatus) ]
                [ formMsg model.testEmailFormStatus emailSuccessMsg
                , div [ A.class "fields" ]
                    [ div [ A.class "four wide field" ]
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
                    , div [ A.class "twelve wide field" ]
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
                    ]
                , button [ A.class "ui violet button", onClick (FirstRunMsg SendTestEmail), A.id "email_send_button" ] [ text "Send" ]
                ]
            ]
        ]


testSmsView : FirstRunModel -> Html Msg
testSmsView model =
    div [ A.id "sent_test_sms" ]
        [ div [ A.class "ui raised segment" ]
            [ h3 [] [ text "Send Test SMS" ]
            , Html.form [ A.class (formClass model.testSmsFormStatus) ]
                [ formMsg model.testSmsFormStatus smsSuccessMsg
                , div [ A.class "fields" ]
                    [ div [ A.class "four wide field" ]
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
                    , div [ A.class "twelve wide field" ]
                        [ label [] [ text "Email Body" ]
                        , input
                            [ A.type_ "text"
                            , A.name "sms-body"
                            , A.placeholder "This is a test"
                            , A.id "sms_body"
                            , onInput (FirstRunMsg << UpdateTestSmsBodyField)
                            ]
                            []
                        ]
                    ]
                , button [ A.class "ui violet button", onClick (FirstRunMsg SendTestSms), A.id "sms_send_button" ] [ text "Send" ]
                ]
            ]
        ]


createAdminView : FirstRunModel -> Html Msg
createAdminView model =
    div [ A.id "create_admin_user" ]
        [ div [ A.class "ui raised segment" ]
            [ h3 [] [ text "Create Admin User" ]
            , Html.form [ A.class (formClass model.adminFormStatus) ]
                [ formMsg model.adminFormStatus adminSuccessMsg
                , div [ A.class "fields" ]
                    [ div [ A.class "eight wide field" ]
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
                    , div [ A.class "four wide field" ]
                        [ label [] [ text "Password" ]
                        , input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass1"
                            , onInput (FirstRunMsg << UpdateAdminPass1Field)
                            ]
                            []
                        ]
                    , div [ A.class "four wide field" ]
                        [ label [] [ text "Password" ]
                        , input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass2"
                            , onInput (FirstRunMsg << UpdateAdminPass2Field)
                            ]
                            []
                        ]
                    ]
                , button
                    [ A.class "ui violet button"
                    , onClick (FirstRunMsg CreateAdminUser)
                    , A.id "create_admin_button"
                    ]
                    [ text "Create" ]
                ]
            ]
        ]


formMsg : FormStatus -> Html Msg -> Html Msg
formMsg status successDiv =
    case status of
        NoAction ->
            text ""

        InProgress ->
            text ""

        Success ->
            successDiv

        Failed e ->
            div [ A.class "ui error message" ]
                [ div [ A.class "header" ] [ text "Uh oh, something went wrong!" ]
                , p [] [ text "Check your settings and try again." ]
                , p [] [ text "Error:" ]
                , pre [] [ text e ]
                ]


adminSuccessMsg : Html Msg
adminSuccessMsg =
    div [ A.class "ui success message" ]
        [ div [ A.class "header" ] [ text "Admin User Created" ]
        , p [] [ text "Refresh this page and you will be able to login" ]
        ]


emailSuccessMsg : Html Msg
emailSuccessMsg =
    div [ A.class "ui success message" ]
        [ div [ A.class "header" ] [ text "Email sent!" ]
        , p [] [ text "Check your inbox to confirm!" ]
        ]


smsSuccessMsg : Html Msg
smsSuccessMsg =
    div [ A.class "ui success message" ]
        [ div [ A.class "header" ] [ text "SMS Sending!" ]
        , p [] [ text "Check your phone to confirm!" ]
        ]
