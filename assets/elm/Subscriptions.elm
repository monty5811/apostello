module Subscriptions exposing (subscriptions)

import Keyboard
import Messages as M
import Models exposing (MenuModel(MenuHidden, MenuVisible), Model)
import PageVisibility
import Pages exposing (Page(Curator, SendAdhoc, SendGroup, Wall))
import Ports exposing (loadDataStore)
import Store.Messages exposing (StoreMsg(LoadData, LoadDataStore))
import Store.Model as Store
import Time exposing (second)
import WebPush


subscriptions : Model -> Sub M.Msg
subscriptions model =
    Sub.batch
        [ reloadData model.pageVisibility model.page model.dataStore
        , getCurrentTime
        , loadDataStore (M.StoreMsg << LoadDataStore)
        , Sub.map M.WebPushMsg <| WebPush.subscriptions model.webPush
        , PageVisibility.visibilityChanges M.VisibilityChange
        , keyUps model
        ]


getCurrentTime : Sub M.Msg
getCurrentTime =
    Time.every (60 * second) (\t -> M.CurrentTime t)


keyUps : Model -> Sub M.Msg
keyUps model =
    case model.menuState of
        MenuHidden ->
            Sub.none

        MenuVisible ->
            Keyboard.ups M.KeyPressed


reloadData : PageVisibility.Visibility -> Page -> Store.DataStore -> Sub M.Msg
reloadData pageVisibility page dataStore =
    let
        allFinished =
            Store.allFinished page dataStore

        anyFailed =
            Store.anyFailed page dataStore
    in
    case page of
        SendAdhoc _ ->
            Sub.none

        SendGroup _ ->
            Sub.none

        _ ->
            let
                interval =
                    case page of
                        Wall ->
                            5 * second

                        Curator ->
                            20 * second

                        _ ->
                            60 * second
            in
            case pageVisibility of
                PageVisibility.Visible ->
                    if allFinished || anyFailed then
                        Time.every interval (\_ -> M.StoreMsg LoadData)
                    else
                        Sub.none

                PageVisibility.Hidden ->
                    Sub.none
