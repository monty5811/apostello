module Forms.Model exposing (..)

import Dict
import Html exposing (Html)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Messages exposing (Msg)
import Pages.Fragments.Notification.Model exposing (DjangoMessage, decodeDjangoMessage)


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


type FormItem
    = FormField Field
    | FormHeader String
    | FieldGroup FieldGroupConfig (List Field)


type alias FieldGroupConfig =
    { header : Maybe String
    , sideBySide : Bool
    , useSegment : Bool
    }


defaultFieldGroupConfig : FieldGroupConfig
defaultFieldGroupConfig =
    FieldGroupConfig Nothing False True


type alias Field =
    { meta : FieldMeta
    , view : List (Html Msg)
    }


type alias FieldMeta =
    { required : Bool
    , id : String
    , name : String
    , label : String
    , help : Maybe String
    }
