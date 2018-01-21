module Pages.Usage exposing (view)

import Html exposing (Html, div, embed, figure, h3, text)
import Html.Attributes as A


view : Html msg
view =
    div
        [ A.style [ ( "margin", "2rem" ) ] ]
        [ row
            [ fig "Contacts" "/graphs/contacts/" "3 / 6"
            , fig "Groups" "/graphs/groups/" "7 / 10"
            , fig "Keywords" "/graphs/keywords/" "11 / 14"
            ]
        , row
            [ fig "Recent Message History" "/graphs/recent/" "1 / 12"
            , fig "Messages" "/graphs/sms/totals/" "13 / 16"
            ]
        , row
            [ fig "Inbound" "/graphs/sms/in/bycontact/" "1 / 8"
            , fig "Outbound" "/graphs/sms/out/bycontact/" "9 / 16"
            ]
        ]


row : List (Html msg) -> Html msg
row l =
    div
        [ A.style
            [ ( "display", "grid" )
            , ( "min-height", "40vh" )
            , ( "grid-template-columns", "repeat(16, auto)" )
            ]
        ]
        l


fig : String -> String -> String -> Html msg
fig header src col =
    div [ A.style [ ( "grid-column", col ) ] ]
        [ h3 [] [ text header ]
        , figure [] [ embed [ A.type_ "image/svg+xml", A.src src ] [] ]
        ]
