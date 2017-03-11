module View.AccessDenied exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Messages exposing (..)


-- Main view


view : Html Msg
view =
    div [ class "ui error message" ]
        [ p [] [ text "Uh, oh, you don't have access to this page." ]
        , p [] []
        , p [] [ text "You'll need to contact the admin that runs this site to get access." ]
        ]
