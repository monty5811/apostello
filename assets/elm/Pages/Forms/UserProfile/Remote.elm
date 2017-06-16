module Pages.Forms.UserProfile.Remote exposing (postCmd)

import Data.User exposing (UserProfile)
import DjangoSend exposing (CSRFToken, rawPost)
import Forms.Helpers exposing (addPk, extractBool, extractFloat)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Pages.Forms.UserProfile.Model exposing (UserProfileFormModel)
import Route exposing (page2loc)
import Urls


postCmd : CSRFToken -> UserProfileFormModel -> UserProfile -> Cmd Msg
postCmd csrf model profile =
    let
        jProfile =
            Just profile

        body =
            [ ( "approved", Encode.bool <| extractBool .approved model.approved jProfile )
            , ( "message_cost_limit", Encode.float <| extractFloat .message_cost_limit model.message_cost_limit jProfile )
            , ( "can_see_groups", Encode.bool <| extractBool .can_see_groups model.can_see_groups jProfile )
            , ( "can_see_contact_names", Encode.bool <| extractBool .can_see_contact_names model.can_see_contact_names jProfile )
            , ( "can_see_keywords", Encode.bool <| extractBool .can_see_keywords model.can_see_keywords jProfile )
            , ( "can_see_outgoing", Encode.bool <| extractBool .can_see_outgoing model.can_see_outgoing jProfile )
            , ( "can_see_incoming", Encode.bool <| extractBool .can_see_incoming model.can_see_incoming jProfile )
            , ( "can_send_sms", Encode.bool <| extractBool .can_send_sms model.can_send_sms jProfile )
            , ( "can_see_contact_nums", Encode.bool <| extractBool .can_see_contact_nums model.can_see_contact_nums jProfile )
            , ( "can_import", Encode.bool <| extractBool .can_import model.can_import jProfile )
            , ( "can_archive", Encode.bool <| extractBool .can_archive model.can_archive jProfile )
            ]
                |> addPk jProfile
    in
    rawPost csrf Urls.api_user_profiles body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.UserProfileTable ])
