module Pages.Forms.SiteConfig.Remote exposing (..)

import DjangoSend exposing (CSRFToken, rawPost)
import Encode exposing (encodeMaybe)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp, ReceiveSiteConfigFormModel), Msg(FormMsg))
import Models exposing (Model)
import Navigation as Nav
import Pages as P
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel, decodeSiteConfigFormModel)
import Route exposing (page2loc)
import Urls


maybeFetchConfig : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchConfig ( model, cmds ) =
    let
        req =
            Http.get Urls.api_site_config decodeSiteConfigFormModel
    in
    case model.page of
        P.SiteConfigForm _ ->
            ( model, cmds ++ [ Http.send (FormMsg << ReceiveSiteConfigFormModel) req ] )

        _ ->
            ( model, cmds )


postCmd : CSRFToken -> SiteConfigFormModel -> Cmd Msg
postCmd csrf model =
    let
        body =
            [ ( "site_name", Encode.string model.site_name )
            , ( "sms_char_limit", Encode.int model.sms_char_limit )
            , ( "default_number_prefix", Encode.string model.default_number_prefix )
            , ( "disable_all_replies", Encode.bool model.disable_all_replies )
            , ( "disable_email_login_form", Encode.bool model.disable_email_login_form )
            , ( "office_email", Encode.string model.office_email )
            , ( "auto_add_new_groups", Encode.list (List.map Encode.int model.auto_add_new_groups) )
            , ( "slack_url", Encode.string model.slack_url )
            , ( "sync_elvanto", Encode.bool model.sync_elvanto )
            , ( "not_approved_msg", Encode.string model.not_approved_msg )
            , ( "email_host", Encode.string model.email_host )
            , ( "email_port", encodeMaybe Encode.int model.email_port )
            , ( "email_username", Encode.string model.email_username )
            , ( "email_password", Encode.string model.email_password )
            , ( "email_from", Encode.string model.email_from )
            ]
    in
    rawPost csrf Urls.api_site_config body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.Home ])
