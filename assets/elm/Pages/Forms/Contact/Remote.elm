module Pages.Forms.Contact.Remote exposing (..)

import Data.Recipient exposing (Recipient)
import DjangoSend exposing (CSRFToken, rawPost)
import Forms.Helpers exposing (addPk, extractBool, extractField)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Pages.Forms.Contact.Model exposing (ContactFormModel)
import Route exposing (page2loc)
import Urls


postCmd : CSRFToken -> ContactFormModel -> Maybe Recipient -> Cmd Msg
postCmd csrf model maybeContact =
    let
        body =
            [ ( "first_name", Encode.string <| extractField .first_name model.first_name maybeContact )
            , ( "last_name", Encode.string <| extractField .last_name model.last_name maybeContact )
            , ( "number", Encode.string <| extractField (Maybe.withDefault "" << .number) model.number maybeContact )
            , ( "do_not_reply", Encode.bool <| extractBool .do_not_reply model.do_not_reply maybeContact )
            ]
                |> addPk maybeContact
    in
    rawPost csrf Urls.api_recipients body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.RecipientTable False ])
