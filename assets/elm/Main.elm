module Main exposing (main)

import Messages exposing (Msg(LoadData, UrlChange))
import Models exposing (Model, Flags, initialModel)
import Models.DjangoMessage exposing (DjangoMessage)
import Navigation
import Route exposing (loc2Page)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import Update.Notification as Notif
import View exposing (view)


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
        |> addDjangoMessages flags.messages
        |> update LoadData


addDjangoMessages : List DjangoMessage -> Model -> Model
addDjangoMessages messages model =
    List.foldl Notif.createFromDjangoMessageNoDestroy model messages
