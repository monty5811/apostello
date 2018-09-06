module Pages.Forms.Meta.Group exposing (meta)

import Form exposing (FieldMeta)


meta : { name : FieldMeta, description : FieldMeta }
meta =
    { name = FieldMeta True "id_name" "name" "Name of group" Nothing
    , description = FieldMeta True "id_description" "description" "Group description" Nothing
    }
