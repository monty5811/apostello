module Pages.Forms.Group.Remote exposing (postCmd)

import Data exposing (RecipientGroup)
import DjangoSend exposing (CSRFToken, rawPost)
import Forms.Helpers exposing (addPk, extractField)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Pages.Forms.Group.Model exposing (GroupFormModel)
import Route exposing (page2loc)
import Urls


postCmd : CSRFToken -> GroupFormModel -> Maybe RecipientGroup -> Cmd Msg
postCmd csrf model maybeGroup =
    let
        body =
            [ ( "name", Encode.string <| extractField .name model.name maybeGroup )
            , ( "description", Encode.string <| extractField .description model.description maybeGroup )
            ]
                |> addPk maybeGroup
    in
    rawPost csrf Urls.api_recipient_groups body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.GroupTable False ])
