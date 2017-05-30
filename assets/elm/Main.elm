module Main exposing (main)

import Messages exposing (Msg(UrlChange))
import Models exposing (Flags, Model, initialModel)
import Navigation
import Pages.Fragments.Notification.Update exposing (addDjangoMessages)
import Route exposing (loc2Page)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
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
        |> update (UrlChange location)
