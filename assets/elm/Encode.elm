module Encode exposing (encodeDate, encodeMaybe, encodeMaybeDate, encodeMaybeDateOnly)

import Date
import Date.Format
import Json.Encode as Encode


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder ms =
    case ms of
        Nothing ->
            Encode.null

        Just s ->
            encoder s


encodeMaybeDate : Maybe Date.Date -> Encode.Value
encodeMaybeDate date =
    date
        |> Maybe.map (Date.Format.format "%Y-%m-%d %H:%M:%S")
        |> encodeMaybe Encode.string


encodeMaybeDateOnly : Maybe Date.Date -> Encode.Value
encodeMaybeDateOnly date =
    date
        |> Maybe.map (Date.Format.format "%Y-%m-%d")
        |> encodeMaybe Encode.string


encodeDate : Date.Date -> Encode.Value
encodeDate date =
    date
        |> Date.Format.format "%Y-%m-%d %H:%M:%S"
        |> Encode.string
