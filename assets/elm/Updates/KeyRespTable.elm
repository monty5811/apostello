module Updates.KeyRespTable exposing (update)

import DjangoSend exposing (archivePost, post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Updates.DataStore exposing (updateSmsInbounds, optArchiveRecordWithPk)
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
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] }, [] )

        ReceiveToggleInboundSmsDealtWith (Err _) ->
            handleNotSaved model

        ArchiveAllCheckBoxClick ->
            ( { model | keyRespTable = not model.keyRespTable }, [] )

        ArchiveAllButtonClick k ->
            ( { model
                | keyRespTable = False
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
        post csrftoken (Urls.keywordArchiveResps keyword) body decodeAlwaysTrue
            |> Http.send (KeyRespTableMsg << ReceiveArchiveAllResp)


optToggleDealtWith : DataStore -> Int -> DataStore
optToggleDealtWith ds pk =
    let
        updatedSms =
            ds.inboundSms
                |> List.map (switchDealtWith pk)
    in
        { ds | inboundSms = updatedSms }


switchDealtWith : Int -> SmsInbound -> SmsInbound
switchDealtWith pk sms =
    if pk == sms.pk then
        { sms | dealt_with = not sms.dealt_with }
    else
        sms


optArchiveMatchingSms : String -> DataStore -> DataStore
optArchiveMatchingSms k ds =
    let
        newInboundSms =
            List.map (archiveMatches k) ds.inboundSms
    in
        { ds | inboundSms = newInboundSms }


archiveMatches : String -> SmsInbound -> SmsInbound
archiveMatches k sms =
    case sms.matched_keyword == k of
        True ->
            { sms | is_archived = True }

        False ->
            sms


optArchiveSms : DataStore -> Int -> DataStore
optArchiveSms ds pk =
    { ds | inboundSms = optArchiveRecordWithPk ds.inboundSms pk }


toggleSmsArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleSmsArchive csrftoken isArchived pk =
    archivePost csrftoken (Urls.smsInbound pk) isArchived smsinboundDecoder
        |> Http.send (KeyRespTableMsg << ReceiveToggleInboundSmsArchive)


toggleSmsDealtWith : CSRFToken -> Bool -> Int -> Cmd Msg
toggleSmsDealtWith csrftoken isDealtWith pk =
    let
        body =
            [ ( "dealt_with", Encode.bool isDealtWith ) ]
    in
        post csrftoken (Urls.smsInbound pk) body smsinboundDecoder
            |> Http.send (KeyRespTableMsg << ReceiveToggleInboundSmsDealtWith)
