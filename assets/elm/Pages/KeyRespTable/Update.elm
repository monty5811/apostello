module Pages.KeyRespTable.Update exposing (update)

import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.Store as Store
import Data.Store.Update exposing (optArchiveRecordWithPk, updateSmsInbounds)
import DjangoSend exposing (archivePost, post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (Msg(KeyRespTableMsg))
import Models exposing (CSRFToken, Model)
import Pages exposing (Page(KeyRespTable))
import Pages.KeyRespTable.Messages exposing (KeyRespTableMsg(..))
import Urls


update : KeyRespTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleInboundSmsArchive isArchived pk ->
            ( { model | dataStore = optArchiveSms model.dataStore pk }
            , [ toggleSmsArchive model.settings.csrftoken isArchived pk ]
            )

        ReceiveToggleInboundSmsArchive (Ok _) ->
            ( model, [] )

        ReceiveToggleInboundSmsArchive (Err _) ->
            handleNotSaved model

        ToggleInboundSmsDealtWith isDealtWith pk ->
            ( { model | dataStore = optToggleDealtWith model.dataStore pk }
            , [ toggleSmsDealtWith model.settings.csrftoken isDealtWith pk ]
            )

        ReceiveToggleInboundSmsDealtWith (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveToggleInboundSmsDealtWith (Err _) ->
            handleNotSaved model

        ArchiveAllCheckBoxClick ->
            let
                page =
                    case model.page of
                        KeyRespTable keyRespModel isArchive k ->
                            KeyRespTable (not keyRespModel) isArchive k

                        _ ->
                            -- ignore if not on the Keyword Response Table Page
                            model.page
            in
            ( { model | page = page }, [] )

        ArchiveAllButtonClick k ->
            let
                page =
                    case model.page of
                        KeyRespTable _ isArchive keywordId ->
                            -- update page to untick box again
                            KeyRespTable False isArchive keywordId

                        _ ->
                            -- ignore if not on the Keyword Response Table Page
                            model.page
            in
            ( { model
                | page = page
                , dataStore = optArchiveMatchingSms k model.dataStore
              }
            , [ archiveAll model.settings.csrftoken k ]
            )

        ReceiveArchiveAllResp _ ->
            ( model, [] )


archiveAll : CSRFToken -> String -> Cmd Msg
archiveAll csrftoken keyword =
    let
        body =
            [ ( "tick_to_archive_all_responses", Encode.bool True ) ]
    in
    post csrftoken (Urls.api_act_keyword_archive_all_responses keyword) body decodeAlwaysTrue
        |> Http.send (KeyRespTableMsg << ReceiveArchiveAllResp)


optToggleDealtWith : Store.DataStore -> Int -> Store.DataStore
optToggleDealtWith ds pk =
    { ds | inboundSms = Store.map (switchDealtWith pk) ds.inboundSms }


switchDealtWith : Int -> SmsInbound -> SmsInbound
switchDealtWith pk sms =
    if pk == sms.pk then
        { sms | dealt_with = not sms.dealt_with }
    else
        sms


optArchiveMatchingSms : String -> Store.DataStore -> Store.DataStore
optArchiveMatchingSms k ds =
    { ds | inboundSms = Store.map (archiveMatches k) ds.inboundSms }


archiveMatches : String -> SmsInbound -> SmsInbound
archiveMatches k sms =
    case sms.matched_keyword == k of
        True ->
            { sms | is_archived = True }

        False ->
            sms


optArchiveSms : Store.DataStore -> Int -> Store.DataStore
optArchiveSms ds pk =
    { ds | inboundSms = Store.map (optArchiveRecordWithPk pk) ds.inboundSms }


toggleSmsArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleSmsArchive csrftoken isArchived pk =
    archivePost csrftoken (Urls.api_act_archive_sms pk) isArchived decodeSmsInbound
        |> Http.send (KeyRespTableMsg << ReceiveToggleInboundSmsArchive)


toggleSmsDealtWith : CSRFToken -> Bool -> Int -> Cmd Msg
toggleSmsDealtWith csrftoken isDealtWith pk =
    let
        body =
            [ ( "dealt_with", Encode.bool isDealtWith ) ]
    in
    post csrftoken (Urls.api_toggle_deal_with_sms pk) body decodeSmsInbound
        |> Http.send (KeyRespTableMsg << ReceiveToggleInboundSmsDealtWith)
