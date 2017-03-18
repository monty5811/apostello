module Subscriptions exposing (subscriptions)

import Messages exposing (Msg(..), SendGroupMsg(UpdateSGDate), SendAdhocMsg(UpdateDate))
import Models exposing (Model, LoadingStatus(..))
import Pages exposing (Page(Curator, Wall, SendAdhoc, SendGroup))
import Ports exposing (updateDateValue, loadDataStore)
import Time exposing (Time, second)


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
    Time.every (60 * second) (\t -> CurrentTime t)


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
                            5 * second

                        Curator ->
                            20 * second

                        _ ->
                            60 * second
            in
                case loadingStatus of
                    FinalPageReceived ->
                        Time.every interval (\_ -> LoadData)

                    RespFailed _ ->
                        Time.every interval (\_ -> LoadData)

                    NoRequestSent ->
                        Sub.none

                    WaitingForFirstResp ->
                        Sub.none

                    WaitingForPage ->
                        Sub.none

                    WaitingOnRefresh ->
                        Sub.none
