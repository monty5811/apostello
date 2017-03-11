module Models.SendAdhocForm exposing (..)

import Date
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional, required, decode)
import Models.DjangoMessage exposing (DjangoMessage, decodeDjangoMessage)
import Models.FormStatus exposing (..)
import Pages exposing (Page(SendAdhoc))
import Regex


type alias SendAdhocModel =
    { content : String
    , selectedContacts : List Int
    , date : Maybe Date.Date
    , errors : SendAdhocFormError
    , status : FormStatus
    , modalOpen : Bool
    , adhocFilter : Regex.Regex
    , cost : Maybe Float
    }


type alias SendAdhocFormResp =
    { messages : List DjangoMessage
    , errors : SendAdhocFormError
    }


type alias SendAdhocFormError =
    { recipients : List String
    , scheduled_time : List String
    , content : List String
    , all : List String
    }


decodeSendAdhocFormError : Decode.Decoder SendAdhocFormError
decodeSendAdhocFormError =
    decode SendAdhocFormError
        |> optional "recipients" (Decode.list Decode.string) []
        |> optional "scheduled_time" (Decode.list Decode.string) []
        |> optional "content" (Decode.list Decode.string) []
        |> optional "__all__" (Decode.list Decode.string) []


decodeSendAdhocFormResp : Decode.Decoder SendAdhocFormResp
decodeSendAdhocFormResp =
    decode SendAdhocFormResp
        |> required "messages" (Decode.list decodeDjangoMessage)
        |> required "errors" decodeSendAdhocFormError


initialSendAdhocModel : Page -> SendAdhocModel
initialSendAdhocModel page =
    let
        initialContent =
            case page of
                SendAdhoc urlContent _ ->
                    urlContent |> Maybe.withDefault ""

                _ ->
                    ""

        initialPks =
            case page of
                SendAdhoc _ pks ->
                    pks

                _ ->
                    Nothing
    in
        { content = initialContent
        , selectedContacts = Maybe.withDefault [] initialPks
        , date = Nothing
        , errors = { recipients = [], scheduled_time = [], content = [], all = [] }
        , status = NoAction
        , modalOpen = False
        , adhocFilter = Regex.regex ""
        , cost = Nothing
        }
