module DjangoSend exposing (..)

import Http exposing (..)
import Json.Decode as Decode
import Models exposing (CSRFToken)


post : String -> Http.Body -> CSRFToken -> Decode.Decoder a -> Request a
post url body csrftoken decoder =
    request
        { method = "POST"
        , headers =
            [ header "X-CSRFToken" csrftoken
            , header "Accept" "application/json"
            ]
        , url = url
        , body = body
        , expect = expectJson decoder
        , timeout = Nothing
        , withCredentials = True
        }
