module Urls exposing (account_change_password, account_email, account_inactive, account_login, account_logout, account_set_password, account_signup, api_act_archive_group, api_act_archive_keyword, api_act_archive_recipient, api_act_archive_sms, api_act_cancel_queued_sms, api_act_create_all_group, api_act_fetch_elvanto_groups, api_act_keyword_archive_all_responses, api_act_permanent_delete, api_act_pull_elvanto_groups, api_act_reingest_sms, api_act_send_adhoc, api_act_send_group, api_act_update_group_members, api_default_responses, api_docs_docs_index, api_docs_schema_js, api_elvanto_groups, api_in_log, api_keywords, api_out_log, api_queued_smss, api_recipient_groups, api_recipients, api_recipients_import_csv, api_setup, api_site_config, api_toggle_deal_with_sms, api_toggle_display_on_wall, api_toggle_elvanto_group_sync, api_user_profile_update, api_user_profiles, api_users, google_callback, google_login, keyword_csv, not_approved, offline, site_config_create_super_user, site_config_first_run, site_config_test_email, site_config_test_sms, socialaccount_connections, socialaccount_login_cancelled, socialaccount_login_error, socialaccount_signup, spa_)


account_change_password : String
account_change_password =
    "/accounts/password/change/"


account_email : String
account_email =
    "/accounts/email/"


account_inactive : String
account_inactive =
    "/accounts/inactive/"


account_login : String
account_login =
    "/accounts/login/"


account_logout : String
account_logout =
    "/accounts/logout/"


account_set_password : String
account_set_password =
    "/accounts/password/set/"


account_signup : String
account_signup =
    "/accounts/signup/"


api_act_archive_group : Int -> String
api_act_archive_group pk =
    "/api/v2/actions/group/archive/" ++ toString pk ++ "/"


api_act_archive_keyword : String -> String
api_act_archive_keyword keyword =
    "/api/v2/actions/keyword/archive/" ++ keyword ++ "/"


api_act_archive_recipient : Int -> String
api_act_archive_recipient pk =
    "/api/v2/actions/recipient/archive/" ++ toString pk ++ "/"


api_act_archive_sms : Int -> String
api_act_archive_sms pk =
    "/api/v2/actions/sms/in/archive/" ++ toString pk ++ "/"


api_act_cancel_queued_sms : Int -> String
api_act_cancel_queued_sms pk =
    "/api/v2/actions/queued/sms/" ++ toString pk ++ "/"


api_act_create_all_group : String
api_act_create_all_group =
    "/api/v2/actions/group/create_all/"


api_act_fetch_elvanto_groups : String
api_act_fetch_elvanto_groups =
    "/api/v2/actions/elvanto/group_fetch/"


api_act_keyword_archive_all_responses : String -> String
api_act_keyword_archive_all_responses keyword =
    "/api/v2/actions/keywords/" ++ keyword ++ "/archive_resps/"


api_act_permanent_delete : String
api_act_permanent_delete =
    "/api/v2/actions/sms/permanent_delete/"


api_act_pull_elvanto_groups : String
api_act_pull_elvanto_groups =
    "/api/v2/actions/elvanto/group_pull/"


api_act_reingest_sms : Int -> String
api_act_reingest_sms pk =
    "/api/v2/actions/sms/in/reingest/" ++ toString pk ++ "/"


api_act_send_adhoc : String
api_act_send_adhoc =
    "/api/v2/actions/sms/send/adhoc/"


api_act_send_group : String
api_act_send_group =
    "/api/v2/actions/sms/send/group/"


api_act_update_group_members : Int -> String
api_act_update_group_members pk =
    "/api/v2/actions/group/update_members/" ++ toString pk ++ "/"


api_default_responses : String
api_default_responses =
    "/api/v2/responses/"


api_docs_docs_index : String
api_docs_docs_index =
    "/api-docs/"


api_docs_schema_js : String
api_docs_schema_js =
    "/api-docs/schema.js"


api_elvanto_groups : String
api_elvanto_groups =
    "/api/v2/elvanto/groups/"


api_in_log : String
api_in_log =
    "/api/v2/sms/in/"


api_keywords : Maybe String -> String
api_keywords keyword =
    "/api/v2/keywords/"
        ++ (case keyword of
                Just b ->
                    toString b ++ "/"

                Nothing ->
                    ""
           )


api_out_log : String
api_out_log =
    "/api/v2/sms/out/"


api_queued_smss : String
api_queued_smss =
    "/api/v2/queued/sms/"


api_recipient_groups : Maybe Int -> String
api_recipient_groups pk =
    "/api/v2/groups/"
        ++ (case pk of
                Just b ->
                    toString b ++ "/"

                Nothing ->
                    ""
           )


api_recipients : Maybe Int -> String
api_recipients pk =
    "/api/v2/recipients/"
        ++ (case pk of
                Just b ->
                    toString b ++ "/"

                Nothing ->
                    ""
           )


api_recipients_import_csv : String
api_recipients_import_csv =
    "/api/v2/recipients/import/csv/"


api_setup : String
api_setup =
    "/api/v2/setup/"


api_site_config : String
api_site_config =
    "/api/v2/config/"


api_toggle_deal_with_sms : Int -> String
api_toggle_deal_with_sms pk =
    "/api/v2/toggle/sms/in/deal_with/" ++ toString pk ++ "/"


api_toggle_display_on_wall : Int -> String
api_toggle_display_on_wall pk =
    "/api/v2/toggle/sms/in/display_on_wall/" ++ toString pk ++ "/"


api_toggle_elvanto_group_sync : Int -> String
api_toggle_elvanto_group_sync pk =
    "/api/v2/toggle/elvanto/group/sync/" ++ toString pk ++ "/"


api_user_profile_update : Int -> String
api_user_profile_update pk =
    "/api/v2/actions/users/profiles/update/" ++ toString pk ++ "/"


api_user_profiles : String
api_user_profiles =
    "/api/v2/users/profiles/"


api_users : String
api_users =
    "/api/v2/users/"


google_callback : String
google_callback =
    "/accounts/google/login/callback/"


google_login : String
google_login =
    "/accounts/google/login/"


keyword_csv : String -> String
keyword_csv keyword =
    "/keyword/responses/csv/" ++ keyword ++ "/"


not_approved : String
not_approved =
    "/not_approved/"


offline : String
offline =
    "/offline/"


site_config_create_super_user : String
site_config_create_super_user =
    "/config/create_admin_user/"


site_config_first_run : String
site_config_first_run =
    "/config/first_run/"


site_config_test_email : String
site_config_test_email =
    "/config/send_test_email/"


site_config_test_sms : String
site_config_test_sms =
    "/config/send_test_sms/"


socialaccount_connections : String
socialaccount_connections =
    "/accounts/social/connections/"


socialaccount_login_cancelled : String
socialaccount_login_cancelled =
    "/accounts/social/login/cancelled/"


socialaccount_login_error : String
socialaccount_login_error =
    "/accounts/social/login/error/"


socialaccount_signup : String
socialaccount_signup =
    "/accounts/social/signup/"


spa_ : String
spa_ =
    "/"
