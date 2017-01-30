module DjangoSend exposing (..)

import Http exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Models exposing (CSRFToken)


post : CSRFToken -> String -> List ( String, Encode.Value ) -> Decode.Decoder a -> Request a
post csrftoken url body decoder =
    request
        { method = "POST"
        , headers =
            [ header "X-CSRFToken" (extractToken csrftoken)
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
    post csrftoken url [ ( "archived", Encode.bool isArchived ) ]


encodeBody : List ( String, Encode.Value ) -> Http.Body
encodeBody data =
    data
        |> Encode.object
        |> Http.jsonBody


extractToken : CSRFToken -> String
extractToken csrftoken =
    case csrftoken of
        Models.CSRFToken token ->
            token
