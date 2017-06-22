module Pages.Forms.SendAdhoc.Remote exposing (postCmd)

import Data.User exposing (UserProfile)
import DjangoSend exposing (CSRFToken, rawPost)
import Encode exposing (encodeMaybeDate)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Pages.Forms.SendAdhoc.Model exposing (SendAdhocModel)
import Route exposing (page2loc)
import Urls


postCmd : CSRFToken -> UserProfile -> SendAdhocModel -> Cmd Msg
postCmd csrf userPerms model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipients", Encode.list (model.selectedContacts |> List.map Encode.int) )
            , ( "scheduled_time", encodeMaybeDate model.date )
            ]

        newLoc =
            case model.date of
                Nothing ->
                    P.OutboundTable

                Just _ ->
                    case userPerms.user.is_staff of
                        True ->
                            P.ScheduledSmsTable

                        False ->
                            P.OutboundTable
    in
    rawPost csrf Urls.api_act_send_adhoc body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc newLoc ])
