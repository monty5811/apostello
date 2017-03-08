module Helpers exposing (..)

import Date
import Date.Format
import Messages exposing (..)
import Models exposing (..)
import Updates.Notification exposing (createNotSavedNotification)


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
