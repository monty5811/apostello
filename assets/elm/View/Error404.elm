module View.Error404 exposing (view)

import Html exposing (Html, div, text)
import Messages exposing (Msg)


view : Html Msg
view =
    div [] [ text "Uh, oh! That page doesn't exist..." ]
