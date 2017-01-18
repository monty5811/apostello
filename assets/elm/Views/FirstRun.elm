module Views.FirstRun exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onWithOptions)
import Json.Decode as Decode
import Messages exposing (..)
import Models exposing (..)


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
    div [ id "sent_test_email" ]
        [ div [ class "ui raised segment" ]
            [ h3 [] [ text "Send Test Email" ]
            , Html.form [ class (formClass model.testEmailFormStatus) ]
                [ formMsg model.testEmailFormStatus emailSuccessMsg
                , div [ class "fields" ]
                    [ div [ class "four wide field" ]
                        [ label [] [ text "Email Address" ]
                        , input
                            [ type_ "email"
                            , name "email-to"
                            , placeholder "test@example.com"
                            , id "email_to"
                            , onInput (FirstRunMsg << UpdateTestEmailToField)
                            ]
                            []
                        ]
                    , div [ class "twelve wide field" ]
                        [ label [] [ text "Email Body" ]
                        , input
                            [ type_ "text"
                            , name "email-body"
                            , placeholder "This is a test"
                            , id "email_body"
                            , onInput (FirstRunMsg << UpdateTestEmailBodyField)
                            ]
                            []
                        ]
                    ]
                , button [ class "ui violet button", onClick (FirstRunMsg SendTestEmail), id "email_send_button" ] [ text "Send" ]
                ]
            ]
        ]


testSmsView : FirstRunModel -> Html Msg
testSmsView model =
    div [ id "sent_test_sms" ]
        [ div [ class "ui raised segment" ]
            [ h3 [] [ text "Send Test SMS" ]
            , Html.form [ class (formClass model.testSmsFormStatus) ]
                [ formMsg model.testSmsFormStatus smsSuccessMsg
                , div [ class "fields" ]
                    [ div [ class "four wide field" ]
                        [ label [] [ text "Phone Number" ]
                        , input
                            [ type_ "text"
                            , name "sms-to"
                            , placeholder "+447095320967"
                            , id "sms_to"
                            , onInput (FirstRunMsg << UpdateTestSmsToField)
                            ]
                            []
                        ]
                    , div [ class "twelve wide field" ]
                        [ label [] [ text "Email Body" ]
                        , input
                            [ type_ "text"
                            , name "sms-body"
                            , placeholder "This is a test"
                            , id "sms_body"
                            , onInput (FirstRunMsg << UpdateTestSmsBodyField)
                            ]
                            []
                        ]
                    ]
                , button [ class "ui violet button", onClick (FirstRunMsg SendTestSms), id "sms_send_button" ] [ text "Send" ]
                ]
            ]
        ]


createAdminView : FirstRunModel -> Html Msg
createAdminView model =
    div [ id "create_admin_user" ]
        [ div [ class "ui raised segment" ]
            [ h3 [] [ text "Create Admin User" ]
            , Html.form [ class (formClass model.adminFormStatus) ]
                [ formMsg model.adminFormStatus adminSuccessMsg
                , div [ class "fields" ]
                    [ div [ class "eight wide field" ]
                        [ label [] [ text "Admin Email" ]
                        , input
                            [ type_ "email"
                            , name "email"
                            , placeholder "you@example.com"
                            , id "admin_email"
                            , onInput (FirstRunMsg << UpdateAdminEmailField)
                            ]
                            []
                        ]
                    , div [ class "four wide field" ]
                        [ label [] [ text "Password" ]
                        , input
                            [ type_ "password"
                            , name "password"
                            , id "admin_pass1"
                            , onInput (FirstRunMsg << UpdateAdminPass1Field)
                            ]
                            []
                        ]
                    , div [ class "four wide field" ]
                        [ label [] [ text "Password" ]
                        , input
                            [ type_ "password"
                            , name "password"
                            , id "admin_pass2"
                            , onInput (FirstRunMsg << UpdateAdminPass2Field)
                            ]
                            []
                        ]
                    ]
                , button [ class "ui violet button", onClick (FirstRunMsg CreateAdminUser), id "create_admin_button" ] [ text "Create" ]
                ]
            ]
        ]


formClass : FormStatus -> String
formClass status =
    case status of
        NoAction ->
            "ui form"

        InProgress ->
            "ui loading form"

        Success ->
            "ui success form"

        Failed _ ->
            "ui error form"


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
            div [ class "ui error message" ]
                [ div [ class "header" ] [ text "Uh oh, something went wrong!" ]
                , p [] [ text "Check your settings and try again." ]
                , p [] [ text "Error:" ]
                , pre [] [ text e ]
                ]


adminSuccessMsg : Html Msg
adminSuccessMsg =
    div [ class "ui success message" ]
        [ div [ class "header" ] [ text "Admin User Created" ]
        , p [] [ text "Refresh this page and you will be able to login" ]
        ]


emailSuccessMsg : Html Msg
emailSuccessMsg =
    div [ class "ui success message" ]
        [ div [ class "header" ] [ text "Email sent!" ]
        , p [] [ text "Check your inbox to confirm!" ]
        ]


smsSuccessMsg : Html Msg
smsSuccessMsg =
    div [ class "ui success message" ]
        [ div [ class "header" ] [ text "SMS Sending!" ]
        , p [] [ text "Check your phone to confirm!" ]
        ]


onClick : msg -> Attribute msg
onClick message =
    let
        options =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "click" options (Decode.succeed message)
