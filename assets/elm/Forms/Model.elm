module Forms.Model exposing (..)

import Dict
import Html exposing (Html)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Notification exposing (DjangoMessage, decodeDjangoMessage)


type FormStatus
    = NoAction
    | InProgress
    | Success
    | Failed FormErrors


type alias FormResp =
    { messages : List DjangoMessage
    , errors : FormErrors
    }


decodeFormResp : Decode.Decoder FormResp
decodeFormResp =
    decode FormResp
        |> required "messages" (Decode.list decodeDjangoMessage)
        |> required "errors" (Decode.dict (Decode.list Decode.string))


type alias FormErrors =
    Dict.Dict String (List String)


noErrors : FormErrors
noErrors =
    Dict.empty


formDecodeError : String -> FormErrors
formDecodeError err =
    Dict.insert "__all__" [ "Something strange happend there. (" ++ err ++ ")" ] noErrors


formErrors : FormStatus -> FormErrors
formErrors formStatus =
    case formStatus of
        Failed errors ->
            errors

        _ ->
            noErrors


type FormItem msg
    = FormField (Field msg)
    | FormHeader String
    | FieldGroup (FieldGroupConfig msg) (List (Field msg))


type alias FieldGroupConfig msg =
    { header : Maybe String
    , helpText : Maybe (Html msg)
    , sideBySide : Maybe Int
    }


defaultFieldGroupConfig : FieldGroupConfig msg
defaultFieldGroupConfig =
    FieldGroupConfig Nothing Nothing Nothing


type alias Field msg =
    { meta : FieldMeta
    , view : List (Html msg)
    }


type alias FieldMeta =
    { required : Bool
    , id : String
    , name : String
    , label : String
    , help : Maybe String
    }
