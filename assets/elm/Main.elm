module Main exposing (..)

import Actions exposing (fetchData)
import Html exposing (programWithFlags)
import Messages exposing (Msg)
import Models exposing (..)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        page =
            decodePage flags.pageId

        model =
            initialModel flags.csrftoken page flags.dataUrl flags.fabData
    in
        ( model, fetchData page flags.dataUrl )


decodePage : String -> Page
decodePage pageId =
    case pageId of
        "fab" ->
            Fab

        "apostello/incoming" ->
            InboundTable

        "apostello/outgoing" ->
            OutboundTable

        "apostello/groups" ->
            GroupTable

        "apostello/groupMembers" ->
            GroupSelect

        "apostello/group_composer" ->
            GroupComposer

        "apostello/recipients" ->
            RecipientTable

        "apostello/keywords" ->
            KeywordTable

        "apostello/wall" ->
            Wall

        "apostello/wall_curator" ->
            Curator

        "elvanto/import" ->
            ElvantoImport

        "apostello/users" ->
            UserProfileTable

        "apostello/scheduled_sms" ->
            ScheduledSmsTable

        "apostello/keyword_responses" ->
            KeyRespTable

        "apostello/first_run" ->
            FirstRun

        _ ->
            Debug.crash "No page found!"
