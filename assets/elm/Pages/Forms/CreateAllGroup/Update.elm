module Pages.Forms.CreateAllGroup.Update exposing (update)

import Pages.Forms.CreateAllGroup.Messages exposing (CreateAllGroupMsg(UpdateGroupName))


update : CreateAllGroupMsg -> String
update (UpdateGroupName text) =
    text
