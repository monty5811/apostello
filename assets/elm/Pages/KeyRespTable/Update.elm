module Pages.KeyRespTable.Update exposing (update)

import Data exposing (SmsInbound)
import DjangoSend exposing (CSRFToken, post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (Msg(KeyRespTableMsg))
import Models exposing (Model)
import Pages exposing (Page(KeyRespTable))
import Pages.KeyRespTable.Messages exposing (KeyRespTableMsg(..))
import RemoteList as RL
import Store.Model as Store
import Urls


update : KeyRespTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
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
archiveAll csrf keyword =
    let
        body =
            [ ( "tick_to_archive_all_responses", Encode.bool True ) ]
    in
    post csrf (Urls.api_act_keyword_archive_all_responses keyword) body decodeAlwaysTrue
        |> Http.send (KeyRespTableMsg << ReceiveArchiveAllResp)


optArchiveMatchingSms : String -> Store.DataStore -> Store.DataStore
optArchiveMatchingSms k ds =
    { ds | inboundSms = RL.map (archiveMatches k) ds.inboundSms }


archiveMatches : String -> SmsInbound -> SmsInbound
archiveMatches k sms =
    case sms.matched_keyword == k of
        True ->
            { sms | is_archived = True }

        False ->
            sms
