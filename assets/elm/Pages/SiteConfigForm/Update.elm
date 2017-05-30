module Pages.SiteConfigForm.Update exposing (update)

import FilteringTable as FT
import Helpers exposing (toggleSelectedPk)
import Pages.SiteConfigForm.Messages exposing (SiteConfigFormMsg(..))
import Pages.SiteConfigForm.Model exposing (SiteConfigFormModel)


update : SiteConfigFormMsg -> SiteConfigFormModel
update msg =
    case msg of
        UpdateSiteNameField model text ->
            { model | site_name = text }

        UpdateSmsCharLimitField model text ->
            case String.toInt text of
                Ok num ->
                    { model | sms_char_limit = num }

                Err _ ->
                    model

        UpdateDefaultPrefixField model text ->
            { model | default_number_prefix = text }

        UpdateDisableRepliesField model ->
            { model | disable_all_replies = not model.disable_all_replies }

        UpdateDisableLoginEmailField model ->
            { model | disable_email_login_form = not model.disable_email_login_form }

        UpdateOfficeEmailField model text ->
            { model | office_email = text }

        UpdateAutoAddGroupsField model pk ->
            { model | auto_add_new_groups = toggleSelectedPk pk model.auto_add_new_groups }

        UpdateSlackUrlField model text ->
            { model | slack_url = text }

        UpdateSyncElvantoField model ->
            { model | sync_elvanto = not model.sync_elvanto }

        UpdateNotApprovedField model text ->
            { model | not_approved_msg = text }

        UpdateEmailHostField model text ->
            { model | email_host = text }

        UpdateEmailPortField model text ->
            case String.toInt text of
                Ok num ->
                    { model | email_port = Just num }

                Err _ ->
                    model

        UpdateEmailUserField model text ->
            { model | email_username = text }

        UpdateEmailPassField model text ->
            { model | email_password = text }

        UpdateEmailFromField model text ->
            { model | email_from = text }

        UpdateGroupsFilter model text ->
            { model | groupsFilter = FT.textToRegex text }
