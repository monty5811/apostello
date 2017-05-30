module Pages.GroupForm.Messages exposing (..)


type GroupFormMsg
    = UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | UpdateGroupNameField String
    | UpdateGroupDescField String
