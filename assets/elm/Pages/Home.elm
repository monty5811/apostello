module Pages.Home exposing (view)

import Html exposing (Html)
import Html.Attributes as A


view : Html msg -> Html msg
view helpLink =
    Html.div []
        [ Html.p [] [ Html.text "Welcome to apostello." ]
        , Html.p []
            [ Html.text "Please bear in mind that each message you send costs "
            , Html.a [ A.href "https://www.twilio.com/sms/pricing" ]
                [ Html.text "money" ]
            , Html.text ", so please do not send frivolous messages."
            ]
        , Html.p []
            [ Html.text "Additionally, try not to send too many messages - do not abuse this system, people do not like being bombarded with messages all day." ]
        , Html.p [] [ helpLink ]
        , Html.br [] []
        , Html.figure []
            [ Html.embed [ A.src "/graphs/recent/", A.type_ "image/svg+xml" ] [] ]
        ]
