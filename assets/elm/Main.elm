module Main exposing (..)

import Models exposing (Flags, Model, initialModel)
import Actions exposing (fetchData)
import Messages exposing (Msg)
import Update exposing (update)
import View exposing (view)
import Html.App exposing (programWithFlags)


main : Program Flags
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags, fetchData flags.csrftoken )
