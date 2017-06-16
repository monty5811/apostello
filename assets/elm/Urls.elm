module Urls exposing (..)


api_queued_smss : String
api_queued_smss =
    "/api/v2/queued/sms/"


account_email_verification_sent : String
account_email_verification_sent =
    "/accounts/confirm-email/"


account_login : String
account_login =
    "/accounts/login/"


api_toggle_deal_with_sms : Int -> String
api_toggle_deal_with_sms pk =
    "/api/v2/toggle/sms/in/deal_with/" ++ toString pk ++ "/"


api_act_cancel_queued_sms : Int -> String
api_act_cancel_queued_sms pk =
    "/api/v2/actions/queued/sms/" ++ toString pk ++ "/"


api_site_config : String
api_site_config =
    "/api/v2/config/"


account_inactive : String
account_inactive =
    "/accounts/inactive/"


socialaccount_login_error : String
socialaccount_login_error =
    "/accounts/social/login/error/"


api_act_update_group_members : Int -> String
api_act_update_group_members pk =
    "/api/v2/actions/group/update_members/" ++ toString pk ++ "/"


api_elvanto_groups : String
api_elvanto_groups =
    "/api/v2/elvanto/groups/"


account_email : String
account_email =
    "/accounts/email/"


site_config_test_sms : String
site_config_test_sms =
    "/config/send_test_sms/"


api_recipient_groups : String
api_recipient_groups =
    "/api/v2/groups/"


account_signup : String
account_signup =
    "/accounts/signup/"


keyword_csv : String -> String
keyword_csv keyword =
    "/keyword/responses/csv/" ++ keyword ++ "/"


api_out_log : String
api_out_log =
    "/api/v2/sms/out/"


offline : String
offline =
    "/offline/"


api_user_profile_update : Int -> String
api_user_profile_update pk =
    "/api/v2/actions/users/profiles/update/" ++ toString pk ++ "/"


spa : String
spa =
    "/"


api_act_archive_group : Int -> String
api_act_archive_group pk =
    "/api/v2/actions/group/archive/" ++ toString pk ++ "/"


account_logout : String
account_logout =
    "/accounts/logout/"


account_confirm_email : String
account_confirm_email =
    "/accounts/confirm-email/<key>/"


account_reset_password_done : String
account_reset_password_done =
    "/accounts/password/reset/done/"


api_act_pull_elvanto_groups : String
api_act_pull_elvanto_groups =
    "/api/v2/actions/elvanto/group_pull/"


api_act_keyword_archive_all_responses : String -> String
api_act_keyword_archive_all_responses keyword =
    "/api/v2/actions/keywords/" ++ keyword ++ "/archive_resps/"


site_config_first_run : String
site_config_first_run =
    "/config/first_run/"


api_recipients_import_csv : String
api_recipients_import_csv =
    "/api/v2/recipients/import/csv/"


api_act_create_all_group : String
api_act_create_all_group =
    "/api/v2/actions/group/create_all/"


google_callback : String
google_callback =
    "/accounts/google/login/callback/"


api_act_archive_recipient : Int -> String
api_act_archive_recipient pk =
    "/api/v2/actions/recipient/archive/" ++ toString pk ++ "/"


not_approved : String
not_approved =
    "/not_approved/"


api_default_responses : String
api_default_responses =
    "/api/v2/responses/"


api_act_send_adhoc : String
api_act_send_adhoc =
    "/api/v2/actions/sms/send/adhoc/"


api_act_fetch_elvanto_groups : String
api_act_fetch_elvanto_groups =
    "/api/v2/actions/elvanto/group_fetch/"


api_keywords : String
api_keywords =
    "/api/v2/keywords/"


site_config_create_super_user : String
site_config_create_super_user =
    "/config/create_admin_user/"


api_act_send_group : String
api_act_send_group =
    "/api/v2/actions/sms/send/group/"


api_act_archive_sms : Int -> String
api_act_archive_sms pk =
    "/api/v2/actions/sms/in/archive/" ++ toString pk ++ "/"


socialaccount_signup : String
socialaccount_signup =
    "/accounts/social/signup/"


account_reset_password : String
account_reset_password =
    "/accounts/password/reset/"


api_users : String
api_users =
    "/api/v2/users/"


account_reset_password_from_key : String
account_reset_password_from_key =
    "/accounts/password/reset/key/<uidb36>-<key>/"


api_setup : String
api_setup =
    "/api/v2/setup/"


account_set_password : String
account_set_password =
    "/accounts/password/set/"


socialaccount_connections : String
socialaccount_connections =
    "/accounts/social/connections/"


api_toggle_display_on_wall : Int -> String
api_toggle_display_on_wall pk =
    "/api/v2/toggle/sms/in/display_on_wall/" ++ toString pk ++ "/"


api_toggle_elvanto_group_sync : Int -> String
api_toggle_elvanto_group_sync pk =
    "/api/v2/toggle/elvanto/group/sync/" ++ toString pk ++ "/"


api_act_reingest_sms : Int -> String
api_act_reingest_sms pk =
    "/api/v2/actions/sms/in/reingest/" ++ toString pk ++ "/"


socialaccount_login_cancelled : String
socialaccount_login_cancelled =
    "/accounts/social/login/cancelled/"


api_recipients : String
api_recipients =
    "/api/v2/recipients/"


drfdocs : String
drfdocs =
    "/api-docs/"


account_change_password : String
account_change_password =
    "/accounts/password/change/"


account_reset_password_from_key_done : String
account_reset_password_from_key_done =
    "/accounts/password/reset/key/done/"


api_act_archive_keyword : String -> String
api_act_archive_keyword keyword =
    "/api/v2/actions/keyword/archive/" ++ keyword ++ "/"


site_config_test_email : String
site_config_test_email =
    "/config/send_test_email/"


api_in_log : String
api_in_log =
    "/api/v2/sms/in/"


api_user_profiles : String
api_user_profiles =
    "/api/v2/users/profiles/"


google_login : String
google_login =
    "/accounts/google/login/"
