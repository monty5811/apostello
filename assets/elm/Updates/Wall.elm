module Updates.Wall exposing (update)

import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Urls
import Updates.DataStore exposing (updateSmsInboundSimples)


update : WallMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleWallDisplay isDisplayed pk ->
            ( model, [ toggleWallDisplay model.settings.csrftoken isDisplayed pk ] )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | dataStore = updateSmsInboundSimples model.dataStore [ sms ] }, [] )

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
        post csrftoken url body smsinboundsimpleDecoder
            |> Http.send (WallMsg << ReceiveToggleWallDisplay)
