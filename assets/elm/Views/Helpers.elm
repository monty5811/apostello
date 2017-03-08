module Views.Helpers exposing (..)

import Html exposing (Attribute, Html, a, td, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Messages exposing (..)
import Models exposing (..)
import Route exposing (page2loc)


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


spaLink : (List (Attribute Msg) -> List (Html Msg) -> Html Msg) -> List (Attribute Msg) -> List (Html Msg) -> Page -> Html Msg
spaLink node attrs nodes page =
    let
        uri =
            page2loc page
    in
        node (List.append [ href uri, onClick <| NewUrl uri ] attrs) nodes


onClick : msg -> Attribute msg
onClick message =
    let
        options =
            { stopPropagation = True
            , preventDefault = True
            }
    in
        onWithOptions "click" options (Decode.succeed message)


formClass : FormStatus -> String
formClass status =
    case status of
        NoAction ->
            "ui form"

        InProgress ->
            "ui loading form"

        Success ->
            "ui success form"

        Failed _ ->
            "ui error form"
