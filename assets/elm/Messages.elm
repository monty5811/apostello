module Messages exposing (..)

import Http
import Models exposing (..)
import ApostelloModels exposing (..)


-- MESSAGES


type Msg
    = LoadData
    | UpdateQueryString String
    | LoadDataSuccess Groups
    | LoadDataError Http.Error
