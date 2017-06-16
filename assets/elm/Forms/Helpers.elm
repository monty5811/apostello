module Forms.Helpers exposing (..)

import Data.Keyword exposing (Keyword)
import Date
import Json.Encode as Encode
import Time


addPk : Maybe { a | pk : Int } -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addPk maybeRecord body =
    case maybeRecord of
        Nothing ->
            body

        Just rec ->
            ( "pk", Encode.int rec.pk ) :: body


extractDate : Time.Time -> (Keyword -> Date.Date) -> Maybe Date.Date -> Maybe Keyword -> Date.Date
extractDate now fn field maybeKeyword =
    case field of
        Nothing ->
            Maybe.map fn maybeKeyword
                |> Maybe.withDefault (Date.fromTime now)

        Just d ->
            d


extractMaybeDate : (Keyword -> Maybe Date.Date) -> Maybe Date.Date -> Maybe Keyword -> Maybe Date.Date
extractMaybeDate fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to ""
            case maybeKeyword of
                Nothing ->
                    Nothing

                Just k ->
                    fn k

        Just s ->
            Just s


extractPks : (Keyword -> List Int) -> Maybe (List Int) -> Maybe Keyword -> List Int
extractPks fn field maybeKeyword =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to []
            Maybe.map fn maybeKeyword
                |> Maybe.withDefault []

        Just pks ->
            pks


extractBool : (a -> Bool) -> Maybe Bool -> Maybe a -> Bool
extractBool fn field maybeRec =
    case field of
        Nothing ->
            Maybe.map fn maybeRec
                |> Maybe.withDefault False

        Just b ->
            b


extractField : (a -> String) -> Maybe String -> Maybe a -> String
extractField fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to ""
            Maybe.map fn maybeRec
                |> Maybe.withDefault ""

        Just s ->
            s


extractFloat : (a -> Float) -> Maybe Float -> Maybe a -> Float
extractFloat fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to 0
            Maybe.map fn maybeRec
                |> Maybe.withDefault 0

        Just s ->
            s
