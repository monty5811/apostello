module Updates.GroupComposer exposing (update)

import Messages exposing (..)
import Models exposing (..)


update : GroupComposerMsg -> Model -> Model
update msg model =
    case msg of
        UpdateQueryString text ->
            { model | groupComposer = updateQueryString text model.groupComposer }


updateQueryString : String -> GroupComposerModel -> GroupComposerModel
updateQueryString string model =
    { model | query = Just string }
