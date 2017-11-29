module Pages.Forms.Meta.UserProfile exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { approved : FieldMeta, message_cost_limit : FieldMeta, can_see_groups : FieldMeta, can_see_contact_names : FieldMeta, can_see_keywords : FieldMeta, can_see_outgoing : FieldMeta, can_see_incoming : FieldMeta, can_send_sms : FieldMeta, can_see_contact_nums : FieldMeta, can_see_contact_notes : FieldMeta, can_import : FieldMeta, can_archive : FieldMeta }
meta =
    { approved = FieldMeta False "id_approved" "approved" "Approved" (Just "This must be true to grant users access to the site.")
    , message_cost_limit = FieldMeta True "id_message_cost_limit" "message_cost_limit" "Message cost limit" (Just "Amount in USD that this user can spend on a single SMS. Note that this is a sanity check, not a security measure - There are no rate limits. If you do not trust a user, revoke their ability to send SMS. Set to zero to disable limit.")
    , can_see_groups = FieldMeta False "id_can_see_groups" "can_see_groups" "Can see groups" Nothing
    , can_see_contact_names = FieldMeta False "id_can_see_contact_names" "can_see_contact_names" "Can see contact names" Nothing
    , can_see_keywords = FieldMeta False "id_can_see_keywords" "can_see_keywords" "Can see keywords" Nothing
    , can_see_outgoing = FieldMeta False "id_can_see_outgoing" "can_see_outgoing" "Can see outgoing" Nothing
    , can_see_incoming = FieldMeta False "id_can_see_incoming" "can_see_incoming" "Can see incoming" Nothing
    , can_send_sms = FieldMeta False "id_can_send_sms" "can_send_sms" "Can send sms" Nothing
    , can_see_contact_nums = FieldMeta False "id_can_see_contact_nums" "can_see_contact_nums" "Can see contact nums" Nothing
    , can_see_contact_notes = FieldMeta False "id_can_see_contact_notes" "can_see_contact_notes" "Can see contact notes" Nothing
    , can_import = FieldMeta False "id_can_import" "can_import" "Can import" Nothing
    , can_archive = FieldMeta False "id_can_archive" "can_archive" "Can archive" Nothing
    }
