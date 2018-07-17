module Pages.Forms.Meta.Contact exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { first_name : FieldMeta, last_name : FieldMeta, number : FieldMeta, do_not_reply : FieldMeta, never_contact : FieldMeta, notes : FieldMeta, groups : FieldMeta }
meta =
    { first_name = FieldMeta True "id_first_name" "first_name" "First Name" Nothing
    , last_name = FieldMeta True "id_last_name" "last_name" "Last Name" Nothing
    , number = FieldMeta True "id_number" "number" "Number" (Just "Cannot be our number, or we get an SMS loop.")
    , do_not_reply = FieldMeta False "id_do_not_reply" "do_not_reply" "Do not reply" (Just "Tick this box to disable automated replies for this person.")
    , never_contact = FieldMeta False "id_never_contact" "never_contact" "Never Contact" (Just "Tick this box to prevent any messages being sent to this person.")
    , notes = FieldMeta False "id_notes" "notes" "Notes" Nothing
    , groups = FieldMeta False "id_groups" "groups" "Groups" Nothing
    }
