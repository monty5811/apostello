port module WebPush
    exposing
        ( Model
        , Msg(CheckSubscribed)
        , initial
        , subscriptions
        , update
        , view
        )

import DjangoSend exposing (CSRFToken, post)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Rocket exposing ((=>))
import Urls


update : CSRFToken -> Msg -> Model -> ( Model, Cmd Msg )
update csrftoken msg model =
    case msg of
        NoOp ->
            model ! []

        CheckSubscribed ->
            model ! [ pushSubEvent "check" ]

        Register ->
            model ! [ pushSubEvent "register" ]

        Unregister ->
            model ! [ pushSubEvent "unregister" ]

        UpdateRecieved eventValue ->
            let
                event =
                    Decode.decodeValue decodeEvent eventValue
            in
            case Debug.log "event" event of
                Err err ->
                    Error ! []

                Ok CheckFailed ->
                    Error ! []

                Ok (RegisterEvent maybeId) ->
                    case maybeId of
                        Nothing ->
                            NotSubscribed ! []

                        Just id ->
                            Subscribed ! [ addId csrftoken id ]

                Ok (UnregisterEvent maybeId) ->
                    case maybeId of
                        Nothing ->
                            Error ! []

                        Just id ->
                            NotSubscribed ! [ removeId csrftoken id ]

                Ok NotSupported ->
                    NoSupport ! []


addId : CSRFToken -> String -> Cmd Msg
addId csrftoken endpoint =
    Http.send (\_ -> NoOp) <|
        post csrftoken Urls.api_act_add_cm_id [ "endpoint" => Encode.string endpoint ] (Decode.succeed ())


removeId : CSRFToken -> String -> Cmd Msg
removeId csrftoken endpoint =
    Http.send (\_ -> NoOp) <|
        post csrftoken Urls.api_act_remove_cm_id [ "endpoint" => Encode.string endpoint ] (Decode.succeed ())


view : Model -> List (Html Msg)
view model =
    [ Html.h4 [] [ Html.text <| "Push Status:" ]
    , Html.div [] [ Html.text <| header model ]
    , case model of
        Unknown ->
            button CheckSubscribed "button-secondary" "Click to check"

        Subscribed ->
            button Unregister "button-info" "Click to stop"

        NotSubscribed ->
            button Register "button-info" "Click to start"

        NoSupport ->
            Html.text ""

        Error ->
            Html.text ""
    ]


header : Model -> String
header m =
    case m of
        Unknown ->
            "Unknown"

        Subscribed ->
            "Subscribed"

        NotSubscribed ->
            "Not Subscribed"

        NoSupport ->
            "Push Not Supported"

        Error ->
            "Error! Reload and try again."


button : Msg -> String -> String -> Html Msg
button msg colour text =
    Html.button
        [ A.class <| "button " ++ colour
        , E.onClick msg
        ]
        [ Html.text text ]


type alias Model =
    Status


type Status
    = Unknown
    | Subscribed
    | NotSubscribed
    | NoSupport
    | Error


initial : Model
initial =
    Unknown


type Msg
    = CheckSubscribed
    | UpdateRecieved Encode.Value
    | Register
    | Unregister
    | NoOp


type SubUpdate
    = CheckFailed
    | RegisterEvent (Maybe String)
    | UnregisterEvent (Maybe String)
    | NotSupported


subscriptions : Model -> Sub Msg
subscriptions model =
    acceptPushSub UpdateRecieved


port acceptPushSub : (Encode.Value -> msg) -> Sub msg


port pushSubEvent : String -> Cmd msg


decodeEvent : Decode.Decoder SubUpdate
decodeEvent =
    Decode.oneOf
        [ decodeFailed
        , decodeRegister
        , decodeUnregister
        , decodeNotSupported
        ]


decodeFailed : Decode.Decoder SubUpdate
decodeFailed =
    Decode.map (\_ -> CheckFailed) <|
        Decode.field "failed" Decode.bool


decodeRegister : Decode.Decoder SubUpdate
decodeRegister =
    Decode.map RegisterEvent <|
        Decode.field "regValue" (Decode.nullable Decode.string)


decodeUnregister : Decode.Decoder SubUpdate
decodeUnregister =
    Decode.map UnregisterEvent <|
        Decode.field "unregValue" (Decode.nullable Decode.string)


decodeNotSupported : Decode.Decoder SubUpdate
decodeNotSupported =
    Decode.map (\_ -> NotSupported) <|
        Decode.field "noSupport" Decode.bool
