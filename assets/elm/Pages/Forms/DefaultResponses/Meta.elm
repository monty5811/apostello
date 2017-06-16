module Pages.Forms.DefaultResponses.Meta exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { keyword_no_match : FieldMeta, default_no_keyword_auto_reply : FieldMeta, default_no_keyword_not_live : FieldMeta, start_reply : FieldMeta, auto_name_request : FieldMeta, name_update_reply : FieldMeta, name_failure_reply : FieldMeta }
meta =
    { keyword_no_match = FieldMeta False "id_keyword_no_match" "keyword_no_match" "Keyword no match" (Just "Reply to use when an SMS does not match any keywords. (\"%name%\" will be replaced with the user's first name)")
    , default_no_keyword_auto_reply = FieldMeta True "id_default_no_keyword_auto_reply" "default_no_keyword_auto_reply" "Default no keyword auto reply" (Just "This message will be sent when an SMS matches a keyword, but that keyword has no reply set.")
    , default_no_keyword_not_live = FieldMeta True "id_default_no_keyword_not_live" "default_no_keyword_not_live" "Default no keyword not live" (Just "Default message for when a keyword is not currently active. (\"%keyword\" will be replaced with the matched keyword)")
    , start_reply = FieldMeta True "id_start_reply" "start_reply" "Start reply" (Just "Reply to use when someone matches \"start\".")
    , auto_name_request = FieldMeta True "id_auto_name_request" "auto_name_request" "Auto name request" (Just "Message to send when we first receive a message from someone not in the contacts list.")
    , name_update_reply = FieldMeta True "id_name_update_reply" "name_update_reply" "Name update reply" (Just "Reply to use when someone matches \"name\". (\"%s\" is replaced with the person's first name)")
    , name_failure_reply = FieldMeta True "id_name_failure_reply" "name_failure_reply" "Name failure reply" (Just "Reply to use when someone matches \"name\" but we are unable to parse their name.")
    }
