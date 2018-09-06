module Pages.AccessDenied exposing (view)

import Html exposing (Html)


-- Main view


view : Html msg
view =
    Html.div []
        [ Html.p [] [ Html.text "Uh, oh, you don't have access to this page." ]
        , Html.p [] []
        , Html.p [] [ Html.text "You'll need to contact the admin that runs this site to get access." ]
        ]
