module Pages.Error404 exposing (view)

import Html exposing (Html)


view : Html msg
view =
    Html.div [] [ Html.text "Uh, oh! That page doesn't exist..." ]
