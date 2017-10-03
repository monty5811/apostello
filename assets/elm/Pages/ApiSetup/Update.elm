module Pages.ApiSetup.Update exposing (update)

import DjangoSend exposing (CSRFToken, post)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(ApiSetupMsg))
import Models exposing (Model)
import Notification as Notif
import Pages as P
import Pages.ApiSetup.Messages exposing (ApiSetupMsg(..))
import Urls


update : ApiSetupMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        Get ->
            ( model, [ Http.get Urls.api_setup decodeToken |> Http.send (ApiSetupMsg << ReceiveApiKey) ] )

        Generate ->
            ( model, [ genKey model.settings.csrftoken ] )

        Delete ->
            ( model, [ delKey model.settings.csrftoken ] )

        ReceiveApiKey (Ok key) ->
            case model.page of
                P.ApiSetup _ ->
                    ( { model | page = P.ApiSetup <| Just key }, [] )

                _ ->
                    ( model, [] )

        ReceiveApiKey (Err _) ->
            case model.page of
                P.ApiSetup _ ->
                    ( { model | notifications = Notif.addRefreshNotif model.notifications }
                    , []
                    )

                _ ->
                    ( model, [] )


genKey : CSRFToken -> Cmd Msg
genKey csrf =
    post csrf Urls.api_setup [ ( "regen", Encode.bool True ) ] decodeToken
        |> Http.send (ApiSetupMsg << ReceiveApiKey)


delKey : CSRFToken -> Cmd Msg
delKey csrf =
    post csrf Urls.api_setup [ ( "delete", Encode.bool True ) ] decodeToken
        |> Http.send (ApiSetupMsg << ReceiveApiKey)


decodeToken : Decode.Decoder String
decodeToken =
    Decode.field "token" Decode.string
