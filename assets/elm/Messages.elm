module Messages exposing (..)

import ApostelloModels exposing (..)
import Http
import Models exposing (..)


-- MESSAGES


type Msg
    = LoadData
    | LoadDataResp (Result Http.Error Groups)
    | UpdateQueryString String
