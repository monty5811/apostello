module Pages.Home exposing (view)

import Html exposing (Html, a, br, div, embed, figure, p, text)
import Html.Attributes exposing (href, src, type_)


view : Html msg -> Html msg
view helpLink =
    div []
        [ p []
            [ text "Welcome to apostello." ]
        , p []
            [ text "Please bear in mind that each message you send costs "
            , a [ href "https://www.twilio.com/sms/pricing" ]
                [ text "money" ]
            , text ", so please do not send frivolous messages."
            ]
        , p []
            [ text "Additionally, try not to send too many messages - do not abuse this system, people do not like being bombarded with messages all day." ]
        , p []
            [ helpLink
            ]
        , br []
            []
        , figure []
            [ embed [ src "/graphs/recent/", type_ "image/svg+xml" ]
                []
            ]
        ]
