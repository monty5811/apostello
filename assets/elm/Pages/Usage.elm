module Pages.Usage exposing (view)

import Css
import Html exposing (Html)
import Html.Attributes as A


view : Html msg
view =
    Html.div
        []
        [ row
            [ fig "Contacts" "/graphs/contacts/"
            , fig "Groups" "/graphs/groups/"
            , fig "Keywords" "/graphs/keywords/"
            ]
        , row
            [ fig "Recent Message History" "/graphs/recent/"
            , fig "Messages" "/graphs/sms/totals/"
            ]
        , row
            [ fig "Inbound" "/graphs/sms/in/bycontact/"
            , fig "Outbound" "/graphs/sms/out/bycontact/"
            ]
        ]


row : List (Html msg) -> Html msg
row l =
    Html.div [ Css.flex, Css.mb_4 ] l


fig : String -> String -> Html msg
fig header src =
    Html.div [ Css.flex_1 ]
        [ Html.h3 [] [ Html.text header ]
        , Html.figure [] [ Html.embed [ A.type_ "image/svg+xml", A.src src ] [] ]
        ]
