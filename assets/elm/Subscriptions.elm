module Subscriptions exposing (subscriptions)

import Messages exposing (..)
import Models exposing (..)
import Time exposing (Time, second)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ queuedSmsTime model.page
        , reloadData model.page model.loadingStatus
        ]


queuedSmsTime : Page -> Sub Msg
queuedSmsTime page =
    case page of
        ScheduledSmsTable ->
            Time.every (10 * second) (\t -> CurrentTime t)

        _ ->
            Sub.none


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
