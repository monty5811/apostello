module Pages.GroupComposer.Model exposing (..)

import Set exposing (Set)


type alias GroupComposerModel =
    Maybe String


initialGroupComposerModel : GroupComposerModel
initialGroupComposerModel =
    Nothing


type alias Query =
    List QueryOp


type QueryOp
    = Union
    | Intersect
    | Diff
    | OpenBracket
    | CloseBracket
    | G (Set Int)
    | NoOp


type alias ParenLoc =
    { open : Maybe Int
    , close : Maybe Int
    }
