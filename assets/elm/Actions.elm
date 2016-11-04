module Actions exposing (..)

import Task exposing (Task)
import Http
import Json.Decode as Decode
import DjangoSend exposing (csrfSend, CSRFToken)
import Decoders exposing (groupDecoder)
import Messages exposing (..)
import ApostelloModels exposing (..)


-- Fetch data from server


fetchData : CSRFToken -> Cmd Msg
fetchData csrftoken =
    csrfSend groupsUrl "GET" Http.empty csrftoken
        |> Http.fromJson (Decode.at [ "results" ] (Decode.list groupDecoder))
        |> Task.perform LoadDataError LoadDataSuccess
