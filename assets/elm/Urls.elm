module Urls exposing (..)


drfdocs : String
drfdocs =
    "/api-docs/"


site_config_first_run : String
site_config_first_run =
    "/config/first_run/"


api_act_send_group : String
api_act_send_group =
    "/api/v2/actions/sms/send/group/"


account_signup : String
account_signup =
    "/accounts/signup/"


api_elvanto_groups : String
api_elvanto_groups =
    "/api/v2/elvanto/groups/"


api_toggle_deal_with_sms : Int -> String
api_toggle_deal_with_sms pk =
    "/api/v2/toggle/sms/in/deal_with/" ++ toString pk ++ "/"


api_act_keyword_archive_all_responses : String -> String
api_act_keyword_archive_all_responses keyword =
    "/api/v2/actions/keywords/" ++ keyword ++ "/archive_resps/"


api_out_log : String
api_out_log =
    "/api/v2/sms/out/"


socialaccount_login_cancelled : String
socialaccount_login_cancelled =
    "/accounts/social/login/cancelled/"


usage_summary : String
usage_summary =
    "/usage/"


api_act_archive_group : Int -> String
api_act_archive_group pk =
    "/api/v2/actions/group/archive/" ++ toString pk ++ "/"


api_act_fetch_elvanto_groups : String
api_act_fetch_elvanto_groups =
    "/api/v2/actions/elvanto/group_fetch/"


site_config_site : String
site_config_site =
    "/config/site/"


user_profile_form : Int -> String
user_profile_form pk =
    "/users/profiles/" ++ toString pk ++ "/"


account_reset_password_done : String
account_reset_password_done =
    "/accounts/password/reset/done/"


api_act_archive_sms : Int -> String
api_act_archive_sms pk =
    "/api/v2/actions/sms/in/archive/" ++ toString pk ++ "/"


keyword_csv : String -> String
keyword_csv keyword =
    "/keyword/responses/csv/" ++ keyword ++ "/"


not_approved : String
not_approved =
    "/not_approved/"


api_in_log : String
api_in_log =
    "/api/v2/sms/in/"


api_queued_smss : String
api_queued_smss =
    "/api/v2/queued/sms/"


account_confirm_email : String
account_confirm_email =
    "/accounts/confirm-email/<key>/"


site_config_responses : String
site_config_responses =
    "/config/responses/"


api_users : String
api_users =
    "/api/v2/users/"


site_config_create_super_user : String
site_config_create_super_user =
    "/config/create_admin_user/"


api_toggle_display_on_wall : Int -> String
api_toggle_display_on_wall pk =
    "/api/v2/toggle/sms/in/display_on_wall/" ++ toString pk ++ "/"


api_act_update_group_members : Int -> String
api_act_update_group_members pk =
    "/api/v2/actions/group/update_members/" ++ toString pk ++ "/"


group_create_all : String
group_create_all =
    "/group/create_all/"


api_site_config : String
api_site_config =
    "/api/v2/config/"


api_toggle_elvanto_group_sync : Int -> String
api_toggle_elvanto_group_sync pk =
    "/api/v2/toggle/elvanto/group/sync/" ++ toString pk ++ "/"


account_reset_password_from_key : String
account_reset_password_from_key =
    "/accounts/password/reset/key/<uidb36>-<key>/"


api_recipient_groups : String
api_recipient_groups =
    "/api/v2/groups/"


google_login : String
google_login =
    "/accounts/google/login/"


account_logout : String
account_logout =
    "/accounts/logout/"


socialaccount_signup : String
socialaccount_signup =
    "/accounts/social/signup/"


api_act_cancel_queued_sms : Int -> String
api_act_cancel_queued_sms pk =
    "/api/v2/actions/queued/sms/" ++ toString pk ++ "/"


account_email_verification_sent : String
account_email_verification_sent =
    "/accounts/confirm-email/"


socialaccount_login_error : String
socialaccount_login_error =
    "/accounts/social/login/error/"


account_email : String
account_email =
    "/accounts/email/"


api_act_reingest_sms : Int -> String
api_act_reingest_sms pk =
    "/api/v2/actions/sms/in/reingest/" ++ toString pk ++ "/"


api_keywords : String
api_keywords =
    "/api/v2/keywords/"


api_user_profile_update : Int -> String
api_user_profile_update pk =
    "/api/v2/actions/users/profiles/update/" ++ toString pk ++ "/"


site_config_test_sms : String
site_config_test_sms =
    "/config/send_test_sms/"


account_change_password : String
account_change_password =
    "/accounts/password/change/"


account_login : String
account_login =
    "/accounts/login/"


account_inactive : String
account_inactive =
    "/accounts/inactive/"


api_recipients : String
api_recipients =
    "/api/v2/recipients/"


api_act_archive_keyword : String -> String
api_act_archive_keyword keyword =
    "/api/v2/actions/keyword/archive/" ++ keyword ++ "/"


account_set_password : String
account_set_password =
    "/accounts/password/set/"


api_setup : String
api_setup =
    "/api-setup/"


account_reset_password : String
account_reset_password =
    "/accounts/password/reset/"


offline : String
offline =
    "/offline/"


socialaccount_connections : String
socialaccount_connections =
    "/accounts/social/connections/"


api_act_archive_recipient : Int -> String
api_act_archive_recipient pk =
    "/api/v2/actions/recipient/archive/" ++ toString pk ++ "/"


google_callback : String
google_callback =
    "/accounts/google/login/callback/"


help : String
help =
    "/help/"


import_recipients : String
import_recipients =
    "/recipient/import/"


account_reset_password_from_key_done : String
account_reset_password_from_key_done =
    "/accounts/password/reset/key/done/"


api_act_pull_elvanto_groups : String
api_act_pull_elvanto_groups =
    "/api/v2/actions/elvanto/group_pull/"


site_config_test_email : String
site_config_test_email =
    "/config/send_test_email/"


api_act_send_adhoc : String
api_act_send_adhoc =
    "/api/v2/actions/sms/send/adhoc/"


api_user_profiles : String
api_user_profiles =
    "/api/v2/users/profiles/"
