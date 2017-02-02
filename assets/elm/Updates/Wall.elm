module Updates.Wall exposing (update, updateSms)

import Decoders exposing (smsinboundsimpleDecoder)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Urls exposing (..)


update : WallMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleWallDisplay isDisplayed pk ->
            ( model, toggleWallDisplay model.csrftoken isDisplayed pk )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | wall = updateSms model.wall [ sms ] }, Cmd.none )

        ReceiveToggleWallDisplay (Err _) ->
            handleNotSaved model


updateSms : WallModel -> List SmsInboundSimple -> WallModel
updateSms model newSms =
    { model
        | sms =
            mergeItems model.sms newSms
                |> sortByTimeReceived
    }


toggleWallDisplay : CSRFToken -> Bool -> Int -> Cmd Msg
toggleWallDisplay csrftoken isDisplayed pk =
    let
        url =
            smsInboundUrl pk

        body =
            [ ( "display_on_wall", Encode.bool isDisplayed ) ]
    in
        post csrftoken url body smsinboundsimpleDecoder
            |> Http.send (WallMsg << ReceiveToggleWallDisplay)
