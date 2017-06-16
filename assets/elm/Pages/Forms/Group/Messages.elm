module Pages.Forms.Group.Messages exposing (..)


type GroupFormMsg
    = UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | UpdateGroupNameField String
    | UpdateGroupDescField String
