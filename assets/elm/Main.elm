module Main exposing (..)

import Messages exposing (..)
import Models exposing (..)
import Navigation
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)
import Route exposing (loc2Page)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    loc2Page location flags.settings
        |> initialModel flags.settings (Maybe.withDefault "" flags.dataStoreCache)
        |> update LoadData
