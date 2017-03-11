module Models.FormStatus exposing (..)


type FormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String
