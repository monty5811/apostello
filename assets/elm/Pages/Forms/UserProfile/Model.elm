module Pages.Forms.UserProfile.Model exposing (UserProfileFormModel, initialUserProfileFormModel)


type alias UserProfileFormModel =
    { approved : Maybe Bool
    , message_cost_limit : Maybe Float
    , can_see_groups : Maybe Bool
    , can_see_contact_names : Maybe Bool
    , can_see_keywords : Maybe Bool
    , can_see_outgoing : Maybe Bool
    , can_see_incoming : Maybe Bool
    , can_send_sms : Maybe Bool
    , can_see_contact_nums : Maybe Bool
    , can_import : Maybe Bool
    , can_archive : Maybe Bool
    }


initialUserProfileFormModel : UserProfileFormModel
initialUserProfileFormModel =
    { approved = Nothing
    , message_cost_limit = Nothing
    , can_see_groups = Nothing
    , can_see_contact_names = Nothing
    , can_see_keywords = Nothing
    , can_see_outgoing = Nothing
    , can_see_incoming = Nothing
    , can_send_sms = Nothing
    , can_see_contact_nums = Nothing
    , can_import = Nothing
    , can_archive = Nothing
    }
