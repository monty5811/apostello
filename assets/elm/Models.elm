module Models exposing (..)

import ApostelloModels exposing (..)
import Json.Decode as Decode


type alias Model =
    { groups : Groups
    , people : People
    , query : Maybe String
    , loadingStatus : LoadingStatus
    }


initialModel : Model
initialModel =
    { groups = []
    , people = []
    , query = Nothing
    , loadingStatus = Waiting
    }


type LoadingStatus
    = Waiting
    | Finished
    | LoadingFailed


type SetOp
    = Union
    | Intersect
    | Diff
    | NoOp


type alias Query =
    { groupPks : List GroupPk
    , ops : List SetOp
    }
