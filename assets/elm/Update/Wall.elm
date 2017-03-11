module Update.Wall exposing (update)

import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Models.Apostello exposing (SmsInbound, decodeSmsInbound)
import Urls
import Update.DataStore exposing (updateSmsInbounds)


update : WallMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleWallDisplay isDisplayed pk ->
            ( model, [ toggleWallDisplay model.settings.csrftoken isDisplayed pk ] )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] }, [] )

        ReceiveToggleWallDisplay (Err _) ->
            handleNotSaved model


toggleWallDisplay : CSRFToken -> Bool -> Int -> Cmd Msg
toggleWallDisplay csrftoken isDisplayed pk =
    let
        url =
            Urls.smsInbound pk

        body =
            [ ( "display_on_wall", Encode.bool isDisplayed ) ]
    in
        post csrftoken url body decodeSmsInbound
            |> Http.send (WallMsg << ReceiveToggleWallDisplay)
