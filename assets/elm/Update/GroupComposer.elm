module Update.GroupComposer exposing (update)

import Messages exposing (Msg, GroupComposerMsg(UpdateQueryString))
import Models exposing (Model)


update : GroupComposerMsg -> Model -> Model
update msg model =
    case msg of
        UpdateQueryString text ->
            { model | groupComposer = Just text }
