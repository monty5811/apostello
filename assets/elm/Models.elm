module Models exposing (..)

import ApostelloModels exposing (..)
import Json.Decode as Decode
import Set exposing (Set)


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


type QueryOp
    = Union
    | Intersect
    | Diff
    | OpenBracket
    | CloseBracket
    | G (Set Int)
    | NoOp


type alias Query =
    List QueryOp


type alias ParenLoc =
    { open : Maybe Int
    , close : Maybe Int
    }
