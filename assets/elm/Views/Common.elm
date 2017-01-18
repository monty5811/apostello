module Views.Common exposing (..)

import Html exposing (..)
import Messages exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, href)


archiveCell : Bool -> Msg -> Html Msg
archiveCell isArchived msg =
    let
        archiveText =
            case isArchived of
                True ->
                    "UnArchive"

                False ->
                    "Archive"
    in
        td [ class "collapsing" ]
            [ a [ class "ui tiny grey button", onClick msg ] [ text archiveText ]
            ]
