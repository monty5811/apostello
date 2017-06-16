module Subscriptions exposing (subscriptions)

import Messages as M
import Models exposing (Model)
import Pages exposing (Page(Curator, SendAdhoc, SendGroup, Wall))
import Ports exposing (loadDataStore)
import Store.Messages exposing (StoreMsg(LoadData, LoadDataStore))
import Store.Model as Store
import Time exposing (Time, second)


subscriptions : Model -> Sub M.Msg
subscriptions model =
    Sub.batch
        [ reloadData model.page model.dataStore
        , getCurrentTime
        , loadDataStore (M.StoreMsg << LoadDataStore)
        ]


getCurrentTime : Sub M.Msg
getCurrentTime =
    Time.every (60 * second) (\t -> M.CurrentTime t)


reloadData : Page -> Store.DataStore -> Sub M.Msg
reloadData page dataStore =
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
            if allFinished then
                Time.every interval (\_ -> M.StoreMsg LoadData)
            else if anyFailed then
                Time.every interval (\_ -> M.StoreMsg LoadData)
            else
                Sub.none
