module Pages.SiteConfigForm.Remote exposing (..)

import Http
import Messages exposing (Msg(ReceiveSiteConfigFormModel))
import Models exposing (Model)
import Pages exposing (Page(SiteConfigForm))
import Pages.SiteConfigForm.Model exposing (decodeSiteConfigFormModel)
import Urls


maybeFetchConfig : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchConfig ( model, cmds ) =
    let
        req =
            Http.get Urls.api_site_config decodeSiteConfigFormModel
    in
    case model.page of
        SiteConfigForm _ ->
            ( model, cmds ++ [ Http.send ReceiveSiteConfigFormModel req ] )

        _ ->
            ( model, cmds )
