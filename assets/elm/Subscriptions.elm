module Subscriptions exposing (subscriptions)

import Messages exposing (..)
import Models exposing (..)
import Time exposing (Time, second)
import Ports exposing (updateDateValue, loadDataStore)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ reloadData model.page model.loadingStatus
        , getCurrentTime
        , updateDateValue (updateDateMsg model.page)
        , loadDataStore LoadDataStore
        ]


updateDateMsg : Page -> (String -> Msg)
updateDateMsg page =
    case page of
        SendAdhoc _ _ ->
            (SendAdhocMsg << UpdateDate)

        SendGroup _ _ ->
            (SendGroupMsg << UpdateSGDate)

        _ ->
            \_ -> Nope


getCurrentTime : Sub Msg
getCurrentTime =
    Time.every (5 * second) (\t -> CurrentTime t)


reloadData : Page -> LoadingStatus -> Sub Msg
reloadData page loadingStatus =
    case page of
        SendAdhoc _ _ ->
            Sub.none

        SendGroup _ _ ->
            Sub.none

        _ ->
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
                    FinalPageReceived ->
                        Time.every interval (\t -> LoadData)

                    RespFailed _ ->
                        Time.every interval (\t -> LoadData)

                    NoRequestSent ->
                        Sub.none

                    WaitingForFirstResp ->
                        Sub.none

                    WaitingForPage ->
                        Sub.none

                    WaitingOnRefresh ->
                        Sub.none
