module DjangoSend exposing (..)

import Http
import Task exposing (Task)


type alias CSRFToken =
    String


csrfSend : String -> String -> Http.Body -> CSRFToken -> Task Http.RawError Http.Response
csrfSend url verb body csrftoken =
    Http.send
        Http.defaultSettings
        { verb = verb
        , headers =
            [ ( "X-CSRFToken", csrftoken )
            , ( "Content-Type", "application/json" )
            ]
        , url = url
        , body = body
        }
