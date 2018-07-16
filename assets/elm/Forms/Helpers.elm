module Forms.Helpers exposing (..)

import Forms.Model exposing (FormStatus(..), decodeFormResp, formDecodeError, noErrors)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Notification as Notif


setInProgress : { a | formStatus : FormStatus } -> { a | formStatus : FormStatus }
setInProgress a =
    { a | formStatus = InProgress }


handleGoodFormResp : List (Cmd msg) -> { body : String, code : Int } -> ( FormStatus, Notif.Notifications, List (Cmd msg) )
handleGoodFormResp okCmds resp =
    case Decode.decodeString decodeFormResp resp.body of
        Ok data ->
            ( Success
            , Notif.createListOfDjangoMessages data.messages
            , okCmds
            )

        Err err ->
            ( Failed <| formDecodeError err, [], [] )


handleBadFormResp : Http.Error -> ( FormStatus, Notif.Notifications )
handleBadFormResp err =
    case err of
        Http.BadStatus resp ->
            case Decode.decodeString decodeFormResp resp.body of
                Ok data ->
                    ( Failed data.errors
                    , Notif.createListOfDjangoMessages data.messages
                    )

                Err e ->
                    ( Failed <| formDecodeError e
                    , [ Notif.refreshNotifMessage ]
                    )

        _ ->
            ( Failed noErrors
            , [ Notif.refreshNotifMessage ]
            )


newHandleFormResp :
    { a | successCmds : List (Cmd msg) }
    -> Result Http.Error { body : String, code : Int }
    -> { c | formStatus : b }
    -> ( { c | formStatus : FormStatus }, Notif.Notifications, List (Cmd msg) )
newHandleFormResp props r model =
    case r of
        Ok resp ->
            let
                ( formStatus, newNotifs, cmds ) =
                    handleGoodFormResp props.successCmds resp
            in
            ( { model
                | formStatus = formStatus
              }
            , newNotifs
            , cmds
            )

        Err err ->
            let
                ( formStatus, newNotifs ) =
                    handleBadFormResp err
            in
            ( { model
                | formStatus = formStatus
              }
            , newNotifs
            , []
            )


addPk : Maybe { a | pk : Int } -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addPk maybeRecord body =
    case maybeRecord of
        Nothing ->
            body

        Just rec ->
            ( "pk", Encode.int rec.pk ) :: body


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
