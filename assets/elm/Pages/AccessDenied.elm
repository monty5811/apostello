module Pages.AccessDenied exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)


-- Main view


view : Html msg
view =
    div [ class "alert alert-danger" ]
        [ p [] [ text "Uh, oh, you don't have access to this page." ]
        , p [] []
        , p [] [ text "You'll need to contact the admin that runs this site to get access." ]
        ]
