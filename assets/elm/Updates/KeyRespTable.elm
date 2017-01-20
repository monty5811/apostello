module Updates.KeyRespTable exposing (update)

import Actions exposing (determineRespCmd)
import Decoders exposing (smsinboundDecoder)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : KeyRespTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadKeyRespTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , keyRespTable = updateSms model.keyRespTable resp.results
              }
            , determineRespCmd KeyRespTable resp
            )

        LoadKeyRespTableResp (Err _) ->
            handleLoadingFailed model

        ToggleInboundSmsArchive isArchived pk ->
            ( { model | keyRespTable = optArchiveSms model.keyRespTable pk }, toggleSmsArchive model.csrftoken isArchived pk )

        ReceiveToggleInboundSmsArchive (Ok _) ->
            ( model, Cmd.none )

        ReceiveToggleInboundSmsArchive (Err _) ->
            handleNotSaved model

        ToggleInboundSmsDealtWith isDealtWith pk ->
            ( { model | keyRespTable = optToggleDealtWith model.keyRespTable pk }, toggleSmsDealtWith model.csrftoken isDealtWith pk )

        ReceiveToggleInboundSmsDealtWith (Ok sms) ->
            ( { model | keyRespTable = updateSms model.keyRespTable [ sms ] }, Cmd.none )

        ReceiveToggleInboundSmsDealtWith (Err _) ->
            handleNotSaved model


updateSms : KeyRespTableModel -> SmsInbounds -> KeyRespTableModel
updateSms model newSms =
    { model | sms = mergeItems model.sms newSms }


optToggleDealtWith : KeyRespTableModel -> Int -> KeyRespTableModel
optToggleDealtWith model pk =
    let
        updatedSms =
            model.sms
                |> List.map (switchDealtWith pk)
    in
        { model | sms = updatedSms }


switchDealtWith : Int -> SmsInbound -> SmsInbound
switchDealtWith pk sms =
    if (pk == sms.pk) then
        { sms | dealt_with = (not sms.dealt_with) }
    else
        sms


optArchiveSms : KeyRespTableModel -> Int -> KeyRespTableModel
optArchiveSms model pk =
    { model | sms = List.filter (\r -> not (r.pk == pk)) model.sms }


toggleSmsArchive : CSRFToken -> Bool -> Int -> Cmd Msg
toggleSmsArchive csrftoken isArchived pk =
    let
        url =
            "/api/v1/sms/in/" ++ (toString pk)

        body =
            encodeBody [ ( "archived", Encode.bool isArchived ) ]
    in
        post url body csrftoken smsinboundDecoder
            |> Http.send (KeyRespTableMsg << ReceiveToggleInboundSmsArchive)


toggleSmsDealtWith : CSRFToken -> Bool -> Int -> Cmd Msg
toggleSmsDealtWith csrftoken isDealtWith pk =
    let
        url =
            "/api/v1/sms/in/" ++ (toString pk)

        body =
            encodeBody [ ( "dealt_with", Encode.bool isDealtWith ) ]
    in
        post url body csrftoken smsinboundDecoder
            |> Http.send (KeyRespTableMsg << ReceiveToggleInboundSmsDealtWith)
