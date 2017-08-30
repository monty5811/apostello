module DjangoSend exposing (CSRFToken(CSRFToken), archivePost, archivePostRaw, post, rawPost)

import Http exposing (Request, expectJson, header, request)
import Json.Decode as Decode
import Json.Encode as Encode
import Rocket exposing ((=>))


type CSRFToken
    = CSRFToken String


post : CSRFToken -> String -> List ( String, Encode.Value ) -> Decode.Decoder a -> Request a
post (CSRFToken csrftoken) url body decoder =
    request
        { method = "POST"
        , headers =
            [ header "X-CSRFToken" csrftoken
            , header "Accept" "application/json"
            ]
        , url = url
        , body = encodeBody body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }


archivePost : CSRFToken -> String -> Bool -> Decode.Decoder a -> Request a
archivePost csrftoken url isArchived =
    post csrftoken url [ "archived" => Encode.bool isArchived ]


archivePostRaw : CSRFToken -> String -> Bool -> Request { body : String, code : Int }
archivePostRaw csrftoken url isArchived =
    rawPost csrftoken url [ "archived" => Encode.bool isArchived ]


encodeBody : List ( String, Encode.Value ) -> Http.Body
encodeBody data =
    data
        |> Encode.object
        |> Http.jsonBody


rawPost : CSRFToken -> String -> List ( String, Encode.Value ) -> Request { body : String, code : Int }
rawPost (CSRFToken csrftoken) url body =
    request
        { method = "POST"
        , headers =
            [ header "X-CSRFToken" csrftoken
            , header "Accept" "application/json"
            ]
        , url = url
        , body = encodeBody body
        , expect = Http.expectStringResponse (\a -> Ok { code = a.status.code, body = a.body })
        , timeout = Nothing
        , withCredentials = True
        }
