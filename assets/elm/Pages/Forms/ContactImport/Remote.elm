module Pages.Forms.ContactImport.Remote exposing (postCmd)

import DjangoSend exposing (CSRFToken, rawPost)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Route exposing (page2loc)
import Urls


postCmd : CSRFToken -> String -> Cmd Msg
postCmd csrf csv =
    let
        body =
            [ ( "csv_data", Encode.string csv ) ]
    in
    rawPost csrf Urls.api_recipients_import_csv body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.Home ])
