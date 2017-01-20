module Subscriptions exposing (subscriptions)

import Messages exposing (..)
import Models exposing (..)
import Time exposing (Time, second)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ reloadData model.page model.loadingStatus
        , getCurrentTime
        , cleanOldNotifications
        ]


getCurrentTime : Sub Msg
getCurrentTime =
    Time.every second (\t -> CurrentTime t)


cleanOldNotifications : Sub Msg
cleanOldNotifications =
    Time.every second (\t -> NotificationMsg (CleanOldNotifications t))


reloadData : Page -> LoadingStatus -> Sub Msg
reloadData page loadingStatus =
    let
        interval =
            case page of
                Wall ->
                    1 * second

                Curator ->
                    10 * second

                _ ->
                    20 * second
    in
        case loadingStatus of
            Finished ->
                Time.every interval (\t -> LoadData WaitingForSubsequent)

            _ ->
                Sub.none
