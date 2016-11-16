module Actions exposing (..)

import ApostelloModels exposing (Groups, groupsUrl)
import Decoders exposing (groupDecoder)
import Http
import Json.Decode as Decode
import Messages exposing (Msg(LoadDataResp))


-- Fetch data from server


getGroups : Http.Request Groups
getGroups =
    Http.request
        { method = "GET"
        , headers = []
        , url = groupsUrl
        , body = Http.emptyBody
        , expect = Http.expectJson (Decode.at [ "results" ] (Decode.list groupDecoder))
        , timeout = Nothing
        , withCredentials = True
        }


fetchData : Cmd Msg
fetchData =
    Http.send LoadDataResp getGroups
