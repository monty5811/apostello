module Pages.Forms.CreateAllGroup.Remote exposing (..)

import DjangoSend exposing (CSRFToken, rawPost)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Route exposing (page2loc)
import Urls


postCmd : CSRFToken -> String -> Cmd Msg
postCmd csrf name =
    let
        body =
            [ ( "group_name", Encode.string name ) ]
    in
    rawPost csrf Urls.api_act_create_all_group body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.GroupTable False ])
