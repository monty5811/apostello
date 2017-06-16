module Pages.Usage exposing (view)

import Html exposing (Html, div, embed, figure, h3, text)
import Html.Attributes exposing (class, src, type_)
import Messages exposing (Msg)


view : Html Msg
view =
    div []
        [ div [ class "ui hidden divder" ] []
        , div [ class "ui stackable centered relaxed padded grid" ]
            [ div [ class "four wide column" ]
                [ h3 [ class "ui header" ] [ text "Contacts" ]
                , figure [] [ embed [ type_ "image/svg+xml", src "/graphs/contacts/" ] [] ]
                ]
            , div [ class "four wide column" ]
                [ h3 [ class "ui header" ] [ text "Groups" ]
                , figure []
                    [ embed [ type_ "image/svg+xml", src "/graphs/groups/" ] [] ]
                ]
            , div [ class "four wide column" ]
                [ h3 [ class "ui header" ] [ text "Keywords" ]
                , figure []
                    [ embed [ type_ "image/svg+xml", src "/graphs/keywords/" ] [] ]
                ]
            , div [ class "twelve wide column" ]
                [ h3 [ class "ui header" ] [ text "Recent Message History" ]
                , figure []
                    [ embed [ type_ "image/svg+xml", src "/graphs/recent/" ] [] ]
                ]
            , div [ class "four wide column" ]
                [ h3 [ class "ui header" ] [ text "Messages" ]
                , figure []
                    [ embed [ type_ "image/svg+xml", src "/graphs/sms/totals/" ] [] ]
                ]
            , div [ class "eight wide column" ]
                [ h3 [ class "ui header" ] [ text "Inbound" ]
                , figure [] [ embed [ type_ "image/svg+xml", src "/graphs/sms/in/bycontact/" ] [] ]
                ]
            , div [ class "eight wide column" ]
                [ h3 [ class "ui header" ] [ text "Outbound" ]
                , figure []
                    [ embed [ type_ "image/svg+xml", src "/graphs/sms/out/bycontact/" ] [] ]
                ]
            ]
        , div [ class "ui hidden divder" ] []
        ]
