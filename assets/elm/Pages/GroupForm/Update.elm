module Pages.GroupForm.Update exposing (update)

import FilteringTable as FT
import Pages.GroupForm.Messages exposing (GroupFormMsg(..))
import Pages.GroupForm.Model exposing (GroupFormModel)


update : GroupFormMsg -> GroupFormModel -> GroupFormModel
update msg model =
    case msg of
        UpdateMemberFilter text ->
            { model | membersFilterRegex = FT.textToRegex text }

        UpdateNonMemberFilter text ->
            { model | nonmembersFilterRegex = FT.textToRegex text }

        UpdateGroupDescField text ->
            { model | description = Just text }

        UpdateGroupNameField text ->
            { model | name = Just text }
