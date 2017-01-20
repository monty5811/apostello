module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Messages exposing (Msg(..))
import Models exposing (..)
import Views.Curator as C
import Views.ElvantoImport as EI
import Views.Fab as F
import Views.FirstRun as FR
import Views.GroupComposer as GC
import Views.GroupMemberSelect as GMS
import Views.GroupTable as GT
import Views.InboundTable as IT
import Views.KeyRespTable as KRT
import Views.KeywordTable as KT
import Views.OutboundTable as OT
import Views.RecipientTable as RT
import Views.ScheduledSmsTable as SST
import Views.Notification as T
import Views.UserProfileTable as UPT
import Views.Wall as W


-- Main view


view : Model -> Html Msg
view model =
    let
        mainView =
            case model.loadingStatus of
                NotAsked ->
                    loadingView

                WaitingForFirst ->
                    loadingView

                WaitingForSubsequent ->
                    loadingCompleteView model

                Finished ->
                    loadingCompleteView model
    in
        div [] ((T.view model) ++ [ mainView ])


loadingCompleteView : Model -> Html Msg
loadingCompleteView model =
    case model.page of
        OutboundTable ->
            OT.view model.filterRegex model.outboundTable

        InboundTable ->
            IT.view model.filterRegex model.inboundTable

        GroupTable ->
            GT.view model.filterRegex model.groupTable

        GroupComposer ->
            GC.view model.groupComposer

        GroupSelect ->
            GMS.view model.groupSelect

        RecipientTable ->
            RT.view model.filterRegex model.recipientTable

        KeywordTable ->
            KT.view model.filterRegex model.keywordTable

        ElvantoImport ->
            EI.view model.filterRegex model.elvantoImport

        Wall ->
            W.view model.wall

        Curator ->
            C.view model.filterRegex model.wall

        UserProfileTable ->
            UPT.view model.filterRegex model.userProfileTable

        ScheduledSmsTable ->
            SST.view model.filterRegex model.currentTime model.scheduledSmsTable

        KeyRespTable ->
            KRT.view model.filterRegex model.keyRespTable

        FirstRun ->
            FR.view model.firstRun

        Fab ->
            F.view model.fabModel



-- Misc


loadingView : Html Msg
loadingView =
    div [ class "row" ]
        [ div [ class "ui active loader" ] []
        ]


errorView : String -> Html Msg
errorView err =
    div [ class "row" ]
        [ div [ class "ui error message" ]
            [ p [] [ text "Uh, oh, something went seriously wrong there." ]
            , p [] [ text "You may not have an internet connection." ]
            , p [] [ text "Please try refreshing the page." ]
            , p [] []
            , p [] [ text err ]
            ]
        ]
