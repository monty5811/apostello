module Pages.Error404 exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes as A
import Messages exposing (Msg)


view : Html Msg
view =
    div [ A.class "alert alert-warning" ] [ text "Uh, oh! That page doesn't exist..." ]
