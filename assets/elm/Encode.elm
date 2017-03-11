module Encode exposing (encodeMaybeDate, encodeMaybe)

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
    case date of
        Just d ->
            Date.Format.format "%Y-%m-%d %H:%M:%S" d
                |> Encode.string

        Nothing ->
            Encode.null
