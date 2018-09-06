module Subscriptions exposing (subscriptions)

import Messages as M
import Models exposing (Model)
import PageVisibility
import Pages exposing (Page(Curator, SendAdhoc, SendGroup, Wall))
import Store.Messages
import Store.Model as Store
import Time exposing (second)


subscriptions : Model -> Sub M.Msg
subscriptions model =
    Sub.batch
        [ reloadData model.pageVisibility model.page model.dataStore
        , getCurrentTime
        , PageVisibility.visibilityChanges M.VisibilityChange
        ]


getCurrentTime : Sub M.Msg
getCurrentTime =
    Time.every (60 * second) (\t -> M.CurrentTime t)


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

                        Curator _ ->
                            20 * second

                        _ ->
                            60 * second
            in
            case pageVisibility of
                PageVisibility.Visible ->
                    if allFinished || anyFailed then
                        Time.every interval (\_ -> M.StoreMsg Store.Messages.LoadData)
                    else
                        Sub.none

                PageVisibility.Hidden ->
                    Sub.none
