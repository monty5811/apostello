module View.Helpers exposing (archiveCell, onClick, formClass, spaLink)

import Html exposing (Attribute, Html, a, td, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Messages exposing (Msg(NewUrl))
import Models.FormStatus
    exposing
        ( FormStatus(NoAction, Failed, Success, InProgress)
        )
import Pages exposing (Page)
import Route exposing (page2loc)


archiveCell : Bool -> Msg -> Html Msg
archiveCell isArchived msg =
    td [ class "collapsing" ]
        [ a [ class "ui tiny grey button", onClick msg ] [ text <| archiveText isArchived ]
        ]


archiveText : Bool -> String
archiveText isArchived =
    case isArchived of
        True ->
            "UnArchive"

        False ->
            "Archive"


onClick : msg -> Attribute msg
onClick message =
    onWithOptions "click" { stopPropagation = True, preventDefault = True } (Decode.succeed message)


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


spaLink : (List (Attribute Msg) -> List (Html Msg) -> Html Msg) -> List (Attribute Msg) -> List (Html Msg) -> Page -> Html Msg
spaLink node attrs nodes page =
    let
        uri =
            page2loc page
    in
        node (List.append [ href uri, spaLinkClick <| NewUrl uri ] attrs) nodes


spaLinkClick : msg -> Attribute msg
spaLinkClick message =
    onWithOptions "click" { stopPropagation = True, preventDefault = True } <|
        Decode.andThen (maybePreventDefault message) <|
            Decode.map3
                (\x y z -> not <| x || y || z)
                (Decode.field "ctrlKey" Decode.bool)
                (Decode.field "metaKey" Decode.bool)
                (Decode.field "shiftKey" Decode.bool)


maybePreventDefault : msg -> Bool -> Decode.Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Decode.succeed msg

        False ->
            Decode.fail "Normal link"
