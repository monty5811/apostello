module Pages.GroupComposer.Update exposing (update)

import Models exposing (Model)
import Pages exposing (Page(GroupComposer))
import Pages.GroupComposer.Messages exposing (GroupComposerMsg(UpdateQueryString))


update : GroupComposerMsg -> Model -> Model
update msg model =
    case ( msg, model.page ) of
        ( UpdateQueryString text, GroupComposer _ ) ->
            { model | page = GroupComposer <| Just text }

        ( _, _ ) ->
            -- ignore messages for other pages
            model
