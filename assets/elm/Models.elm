module Models exposing (..)

import Json.Decode as Decode
import ApostelloModels exposing (..)
import DjangoSend exposing (CSRFToken)


type alias Flags =
    { csrftoken : CSRFToken
    }


type alias Model =
    { groups : Groups
    , people : People
    , csrftoken : CSRFToken
    , query : Maybe String
    , loadingStatus : LoadingStatus
    }


initialModel : Flags -> Model
initialModel flags =
    { groups = []
    , people = []
    , csrftoken = flags.csrftoken
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
