module View.Error404 exposing (view)

import Html exposing (..)
import Messages exposing (..)


view : Html Msg
view =
    div [] [ text "Uh, oh! That page doesn't exist..." ]
