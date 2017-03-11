module Helpers exposing (handleNotSaved, formatDate, calculateSmsCost, decodeAlwaysTrue)

import Date
import Date.Format
import Json.Decode as Decode
import Messages exposing (Msg)
import Models exposing (Model)
import Update.Notification exposing (createNotSavedNotification)


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True



-- update model after http errors:


handleNotSaved : Model -> ( Model, List (Cmd Msg) )
handleNotSaved model =
    ( createNotSavedNotification model, [] )



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
