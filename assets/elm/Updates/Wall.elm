module Updates.Wall exposing (update)

import Actions exposing (determineRespCmd)
import Decoders exposing (smsinboundsimpleDecoder)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : WallMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadWallResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , wall = updateSms model.wall resp.results
              }
            , determineRespCmd Wall resp
            )

        LoadWallResp (Err _) ->
            handleLoadingFailed model

        ToggleWallDisplay isDisplayed pk ->
            ( model, toggleWallDisplay model.csrftoken isDisplayed pk )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | wall = updateSms model.wall [ sms ] }, Cmd.none )

        ReceiveToggleWallDisplay (Err _) ->
            handleNotSaved model


updateSms : WallModel -> List SmsInboundSimple -> WallModel
updateSms model newSms =
    { model | sms = mergeItems model.sms newSms }


toggleWallDisplay : CSRFToken -> Bool -> Int -> Cmd Msg
toggleWallDisplay csrftoken isDisplayed pk =
    let
        url =
            "/api/v1/sms/in/" ++ (toString pk)

        body =
            encodeBody [ ( "display_on_wall", Encode.bool isDisplayed ) ]
    in
        post url body csrftoken smsinboundsimpleDecoder
            |> Http.send (WallMsg << ReceiveToggleWallDisplay)
