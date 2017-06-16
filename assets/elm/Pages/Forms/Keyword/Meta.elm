module Pages.Forms.Keyword.Meta exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { keyword : FieldMeta, description : FieldMeta, disable_all_replies : FieldMeta, custom_response : FieldMeta, deactivated_response : FieldMeta, too_early_response : FieldMeta, activate_time : FieldMeta, deactivate_time : FieldMeta, linked_groups : FieldMeta, owners : FieldMeta, subscribed_to_digest : FieldMeta }
meta =
    { keyword = FieldMeta True "id_keyword" "keyword" "Keyword" Nothing
    , description = FieldMeta True "id_description" "description" "Keyword Description" Nothing
    , disable_all_replies = FieldMeta False "id_disable_all_replies" "disable_all_replies" "Disable all replies" (Just "If checked, then we will never reply to this keyword.Note that users may still be asked for their name if they are new.")
    , custom_response = FieldMeta False "id_custom_response" "custom_response" "Auto response" (Just "This text will be sent back as a reply when any incoming message matches this keyword. If empty, the site wide response will be used.")
    , deactivated_response = FieldMeta False "id_deactivated_response" "deactivated_response" "Deactivated response" (Just "Use this if you want a custom response after deactivation. e.g. 'You are too late for this event, sorry!'")
    , too_early_response = FieldMeta False "id_too_early_response" "too_early_response" "Not yet activated response" (Just "Use this if you want a custom response before. e.g. 'You are too early for this event, please try again on Monday!'")
    , activate_time = FieldMeta True "id_activate_time" "activate_time" "Activation Time" (Just "The keyword will not be active before this time and so no messages will be able to match it. Leave blank to activate now.")
    , deactivate_time = FieldMeta False "id_deactivate_time" "deactivate_time" "Deactivation Time" (Just "The keyword will not be active after this time and so no messages will be able to match it. Leave blank to never deactivate.")
    , linked_groups = FieldMeta False "id_linked_groups" "linked_groups" "Linked groups" (Just "Contacts that match this keyword will be added to the selected groups.")
    , owners = FieldMeta False "id_owners" "owners" "Limit viewing to only these people" (Just "If this field is empty, any user can see this keyword. If populated, then only the named users and staff will have access.")
    , subscribed_to_digest = FieldMeta False "id_subscribed_to_digest" "subscribed_to_digest" "Subscribed to daily emails." (Just "Choose users that will receive daily updates of matched messages.")
    }
