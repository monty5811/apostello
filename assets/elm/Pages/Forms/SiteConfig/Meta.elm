module Pages.Forms.SiteConfig.Meta exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { site_name : FieldMeta, sms_char_limit : FieldMeta, default_number_prefix : FieldMeta, disable_all_replies : FieldMeta, disable_email_login_form : FieldMeta, office_email : FieldMeta, auto_add_new_groups : FieldMeta, slack_url : FieldMeta, sync_elvanto : FieldMeta, not_approved_msg : FieldMeta, email_host : FieldMeta, email_port : FieldMeta, email_username : FieldMeta, email_password : FieldMeta, email_from : FieldMeta }
meta =
    { site_name = FieldMeta True "id_site_name" "site_name" "Site name" Nothing
    , sms_char_limit = FieldMeta True "id_sms_char_limit" "sms_char_limit" "Sms char limit" (Just "SMS length limit. The sending forms use this value to limit the size of messages. Check the Twilio pricing docs for pricing information.")
    , default_number_prefix = FieldMeta False "id_default_number_prefix" "default_number_prefix" "Default number prefix" (Just "This value will be used to prepopulate the new contact form use this if you don't want to have to type +xx every time.")
    , disable_all_replies = FieldMeta False "id_disable_all_replies" "disable_all_replies" "Disable all replies" (Just "Tick this box to disable all automated replies.")
    , disable_email_login_form = FieldMeta False "id_disable_email_login_form" "disable_email_login_form" "Disable email login form" (Just "Tick this to hide the login with email form. Note, you will need to have setup login with Google, or users will have no way into the site.")
    , office_email = FieldMeta False "id_office_email" "office_email" "Office email" (Just "Email address that receives important notifications.")
    , auto_add_new_groups = FieldMeta False "id_auto_add_new_groups" "auto_add_new_groups" "Auto add new groups" (Just "Any brand new people will be added to the groups selected here")
    , slack_url = FieldMeta False "id_slack_url" "slack_url" "Slack url" (Just "Post all incoming messages to this slack hook. Leave blank to disable.")
    , sync_elvanto = FieldMeta False "id_sync_elvanto" "sync_elvanto" "Sync elvanto" (Just "Toggle automatic syncing of Elvanto groups. Syncing will be done every 24 hours.")
    , not_approved_msg = FieldMeta True "id_not_approved_msg" "not_approved_msg" "Not approved msg" (Just "This message will be shown on the \"not approved\" page.")
    , email_host = FieldMeta False "id_email_host" "email_host" "Email host" (Just "Email host. This will override values in settings.py")
    , email_port = FieldMeta False "id_email_port" "email_port" "Email port" (Just "Email host port. This will override values in settings.py")
    , email_username = FieldMeta False "id_email_username" "email_username" "Email username" (Just "Email user name. This will override values in settings.py")
    , email_password = FieldMeta False "id_email_password" "email_password" "Email password" (Just "Email password. This will override values in settings.py")
    , email_from = FieldMeta False "id_email_from" "email_from" "Email from" (Just "Email will be sent from this address. This will override values in settings.py")
    }
