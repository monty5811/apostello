module Pages.Forms.Keyword.Remote exposing (postCmd)

import Data exposing (Keyword)
import DjangoSend exposing (CSRFToken, rawPost)
import Encode exposing (encodeDate, encodeMaybeDate)
import Forms.Helpers exposing (addPk, extractBool, extractDate, extractField, extractMaybeDate, extractPks)
import Http
import Json.Encode as Encode
import Messages exposing (FormMsg(ReceiveFormResp), Msg(FormMsg))
import Navigation as Nav
import Pages as P
import Pages.Forms.Keyword.Model exposing (KeywordFormModel)
import Route exposing (page2loc)
import Time
import Urls


postCmd : CSRFToken -> Time.Time -> KeywordFormModel -> Maybe Keyword -> Cmd Msg
postCmd csrf now model maybeKeyword =
    let
        body =
            [ ( "keyword", Encode.string <| extractField .keyword model.keyword maybeKeyword )
            , ( "description", Encode.string <| extractField .description model.description maybeKeyword )
            , ( "disable_all_replies", Encode.bool <| extractBool .disable_all_replies model.disable_all_replies maybeKeyword )
            , ( "custom_response", Encode.string <| extractField .custom_response model.custom_response maybeKeyword )
            , ( "deactivated_response", Encode.string <| extractField .deactivated_response model.deactivated_response maybeKeyword )
            , ( "too_early_response", Encode.string <| extractField .too_early_response model.too_early_response maybeKeyword )
            , ( "activate_time", encodeDate <| extractDate now .activate_time model.activate_time maybeKeyword )
            , ( "deactivate_time", encodeMaybeDate <| extractMaybeDate .deactivate_time model.deactivate_time maybeKeyword )
            , ( "linked_groups", Encode.list <| List.map Encode.int <| extractPks .linked_groups model.linked_groups maybeKeyword )
            , ( "owners", Encode.list <| List.map Encode.int <| extractPks .owners model.owners maybeKeyword )
            , ( "subscribed_to_digest", Encode.list <| List.map Encode.int <| extractPks .subscribed_to_digest model.subscribers maybeKeyword )
            ]
                |> addPk maybeKeyword
    in
    rawPost csrf (Urls.api_keywords Nothing) body
        |> Http.send (FormMsg << ReceiveFormResp [ Nav.newUrl <| page2loc <| P.KeywordTable False ])
