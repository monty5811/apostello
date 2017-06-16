module Pages.Forms.CreateAllGroup.Meta exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { group_name : FieldMeta }
meta =
    { group_name = FieldMeta True "id_group_name" "group_name" "Group Name" (Just "Name of group.\nIf this group already exists it will be overwritten.")
    }
