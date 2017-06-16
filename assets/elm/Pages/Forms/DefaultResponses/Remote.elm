module Pages.Forms.DefaultResponses.Remote exposing (..)

import DjangoSend exposing (CSRFToken, rawPost)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveDefaultResponsesFormModel, ReceiveFormResp), Msg(FormMsg))
import Models exposing (Model)
import Navigation as Nav
import Pages as P
import Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel, decodeDefaultResponsesFormModel)
import Route exposing (page2loc)
import Urls


maybeFetchResps : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchResps ( model, cmds ) =
    let
        req =
            Http.get Urls.api_default_responses decodeDefaultResponsesFormModel
    in
    case model.page of
        P.DefaultResponsesForm _ ->
            ( model, cmds ++ [ Http.send (FormMsg << ReceiveDefaultResponsesFormModel) req ] )

        _ ->
            ( model, cmds )


postCmd : CSRFToken -> DefaultResponsesFormModel -> Cmd Msg
postCmd csrf model =
    let
        body =
            [ ( "keyword_no_match", Encode.string model.keyword_no_match )
            , ( "default_no_keyword_auto_reply", Encode.string model.default_no_keyword_auto_reply )
            , ( "default_no_keyword_not_live", Encode.string model.default_no_keyword_not_live )
            , ( "start_reply", Encode.string model.start_reply )
            , ( "auto_name_request", Encode.string model.auto_name_request )
            , ( "name_update_reply", Encode.string model.name_update_reply )
            , ( "name_failure_reply", Encode.string model.name_failure_reply )
            ]
    in
    rawPost csrf Urls.api_default_responses body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc P.Home ])
