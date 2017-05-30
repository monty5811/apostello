module Data.Keyword exposing (Keyword, decodeKeyword, encodeKeyword)

import Date
import Encode exposing (encodeDate, encodeMaybeDate)
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias Keyword =
    { keyword : String
    , pk : Int
    , description : String
    , current_response : String
    , is_live : Bool
    , url : String
    , responses_url : String
    , num_replies : String
    , num_archived_replies : String
    , is_archived : Bool
    , disable_all_replies : Bool
    , custom_response : String
    , deactivated_response : String
    , too_early_response : String
    , activate_time : Date.Date
    , deactivate_time : Maybe Date.Date
    , linked_groups : List Int
    , owners : List Int
    , subscribed_to_digest : List Int
    }


decodeKeyword : Decode.Decoder Keyword
decodeKeyword =
    decode Keyword
        |> required "keyword" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> required "current_response" Decode.string
        |> required "is_live" Decode.bool
        |> required "url" Decode.string
        |> required "responses_url" Decode.string
        |> required "num_replies" Decode.string
        |> required "num_archived_replies" Decode.string
        |> required "is_archived" Decode.bool
        |> required "disable_all_replies" Decode.bool
        |> required "custom_response" Decode.string
        |> required "deactivated_response" Decode.string
        |> required "too_early_response" Decode.string
        |> required "activate_time" date
        |> required "deactivate_time" (Decode.maybe date)
        |> required "linked_groups" (Decode.list Decode.int)
        |> required "owners" (Decode.list Decode.int)
        |> required "subscribed_to_digest" (Decode.list Decode.int)


encodeKeyword : Keyword -> Encode.Value
encodeKeyword keyword =
    Encode.object
        [ ( "keyword", Encode.string keyword.keyword )
        , ( "pk", Encode.int keyword.pk )
        , ( "description", Encode.string keyword.description )
        , ( "current_response", Encode.string keyword.current_response )
        , ( "is_live", Encode.bool keyword.is_live )
        , ( "url", Encode.string keyword.url )
        , ( "responses_url", Encode.string keyword.responses_url )
        , ( "num_replies", Encode.string keyword.num_replies )
        , ( "num_archived_replies", Encode.string keyword.num_archived_replies )
        , ( "is_archived", Encode.bool keyword.is_archived )
        , ( "disable_all_replies", Encode.bool keyword.disable_all_replies )
        , ( "custom_response", Encode.string keyword.custom_response )
        , ( "deactivated_response", Encode.string keyword.deactivated_response )
        , ( "too_early_response", Encode.string keyword.too_early_response )
        , ( "activate_time", encodeDate keyword.activate_time )
        , ( "deactivate_time", encodeMaybeDate keyword.deactivate_time )
        , ( "linked_groups", Encode.list (List.map Encode.int keyword.linked_groups) )
        , ( "owners", Encode.list (List.map Encode.int keyword.owners) )
        , ( "subscribed_to_digest", Encode.list (List.map Encode.int keyword.subscribed_to_digest) )
        ]
