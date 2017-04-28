module Models.SendGroupForm exposing (..)

import Date
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required, decode)
import Models.DjangoMessage exposing (DjangoMessage, decodeDjangoMessage)
import Models.FormStatus exposing (..)
import Pages exposing (Page(SendGroup))
import Regex


type alias SendGroupModel =
    { content : String
    , date : Maybe Date.Date
    , errors : SendGroupFormError
    , status : FormStatus
    , selectedPk : Maybe Int
    , cost : Maybe Float
    , groupFilter : Regex.Regex
    }


type alias SendGroupFormResp =
    { messages : List DjangoMessage
    , errors : SendGroupFormError
    }


type alias SendGroupFormError =
    { group : List String
    , scheduled_time : List String
    , content : List String
    , all : List String
    }


initialSendGroupModel : Page -> SendGroupModel
initialSendGroupModel page =
    let
        initialContent =
            case page of
                SendGroup urlContent _ ->
                    urlContent

                _ ->
                    Nothing

        initialSelectedGroup =
            case page of
                SendGroup _ pk ->
                    pk

                _ ->
                    Nothing
    in
        { content = Maybe.withDefault "" initialContent
        , selectedPk = initialSelectedGroup
        , date = Nothing
        , errors = { group = [], scheduled_time = [], content = [], all = [] }
        , status = NoAction
        , cost = Nothing
        , groupFilter = Regex.regex ""
        }


decodeSendGroupFormResp : Decode.Decoder SendGroupFormResp
decodeSendGroupFormResp =
    decode SendGroupFormResp
        |> required "messages" (Decode.list decodeDjangoMessage)
        |> required "errors" decodeSendGroupFormError


decodeSendGroupFormError : Decode.Decoder SendGroupFormError
decodeSendGroupFormError =
    decode SendGroupFormError
        |> optional "group" (Decode.list Decode.string) []
        |> optional "scheduled_time" (Decode.list Decode.string) []
        |> optional "content" (Decode.list Decode.string) []
        |> optional "__all__" (Decode.list Decode.string) []
