module Pages.Wall.Update exposing (update)

import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.Store.Update exposing (updateSmsInbounds)
import DjangoSend exposing (post)
import Helpers exposing (handleNotSaved)
import Http
import Json.Encode as Encode
import Messages exposing (Msg)
import Models exposing (..)
import Pages.Wall.Messages
    exposing
        ( WallMsg
            ( ReceiveToggleWallDisplay
            , ToggleWallDisplay
            )
        )
import Urls


update : WallMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleWallDisplay isDisplayed pk ->
            ( model, [ toggleWallDisplay model.settings.csrftoken isDisplayed pk ] )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveToggleWallDisplay (Err _) ->
            handleNotSaved model


toggleWallDisplay : CSRFToken -> Bool -> Int -> Cmd Msg
toggleWallDisplay csrftoken isDisplayed pk =
    let
        url =
            Urls.api_toggle_display_on_wall pk

        body =
            [ ( "display_on_wall", Encode.bool isDisplayed ) ]
    in
    post csrftoken url body decodeSmsInbound
        |> Http.send (Messages.WallMsg << ReceiveToggleWallDisplay)
