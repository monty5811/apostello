module Helpers exposing (..)

import Date
import Date.Format
import Html exposing (Attribute, Html, a, td, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import List.Extra as LE
import Messages exposing (Msg)
import Models exposing (Model)
import Pages.Fragments.Notification.Update as Notif


toggleSelectedPk : Int -> List Int -> List Int
toggleSelectedPk pk pks =
    case List.member pk pks of
        True ->
            LE.remove pk pks

        False ->
            pk :: pks


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True



-- update model after http errors:


handleNotSaved : Model -> ( Model, List (Cmd Msg) )
handleNotSaved model =
    let
        ( newModel, cmd ) =
            Notif.createNotSaved model
    in
    ( newModel, [ cmd ] )



-- Pretty date format


formatDate : Maybe Date.Date -> String
formatDate date =
    case date of
        Just d ->
            Date.Format.format "%H:%M - %d %b" d

        Nothing ->
            ""



-- calculate cost of sending an sms


calculateSmsCost : Float -> String -> Float
calculateSmsCost smsCostPerMsg msg =
    msg
        |> String.length
        |> toFloat
        |> flip (/) 160
        |> ceiling
        |> toFloat
        |> (*) smsCostPerMsg


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
