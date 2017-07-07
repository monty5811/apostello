module Pages.Forms.SiteConfig.View exposing (view)

import Data exposing (RecipientGroup)
import Date
import DateTimePicker
import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup), FormStatus, defaultFieldGroupConfig)
import Forms.View as FV
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Messages exposing (FormMsg(PostForm, SiteConfigFormMsg), Msg(FormMsg, Nope))
import Pages.Forms.SiteConfig.Messages exposing (SiteConfigFormMsg(..))
import Pages.Forms.SiteConfig.Meta exposing (meta)
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)
import Pages.Forms.SiteConfig.Remote exposing (postCmd)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL
import Store.Model exposing (DataStore, filterArchived)


-- Main view


view : CSRFToken -> DataStore -> Maybe SiteConfigFormModel -> FormStatus -> Html Msg
view csrf dataStore maybeModel status =
    case maybeModel of
        Nothing ->
            loader

        Just model ->
            let
                groups =
                    filterArchived False dataStore.groups

                fields =
                    fieldsHelp groups model
            in
            FV.form status
                fields
                (FormMsg <| PostForm <| postCmd csrf model)
                (FV.submitButton (Just model) False)


fieldsHelp : RL.RemoteList RecipientGroup -> SiteConfigFormModel -> List FormItem
fieldsHelp groups model =
    [ FieldGroup { defaultFieldGroupConfig | header = Just "Site Settings" }
        [ Field meta.site_name (siteNameField meta.site_name model)
        , Field meta.disable_email_login_form (emailLoginField meta.disable_email_login_form model)
        , Field meta.not_approved_msg (notAppField meta.not_approved_msg model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "SMS Settings" }
        [ Field meta.sms_char_limit (smsLimitField meta.sms_char_limit model)
        , Field meta.default_number_prefix (defaultPrefixField meta.default_number_prefix model)
        , Field meta.disable_all_replies (allRepliesField meta.disable_all_replies model)
        , Field meta.auto_add_new_groups (autoNewGroupsField groups meta.auto_add_new_groups model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "SMS Expiration", sideBySide = True }
        [ Field meta.sms_expiration_date (smsExpirationDateField meta.sms_expiration_date model)
        , Field meta.sms_rolling_expiration_days (smsRollingExpireField meta.sms_rolling_expiration_days model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "Notification Settings" }
        [ Field meta.office_email (officeEmailField meta.office_email model)
        , Field meta.slack_url (slackField meta.slack_url model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "Sending Email Settings" }
        [ Field meta.email_host (emailHostField meta.email_host model)
        , Field meta.email_port (emailPortField meta.email_port model)
        , Field meta.email_username (emailUserField meta.email_username model)
        , Field meta.email_password (emailPassField meta.email_password model)
        , Field meta.email_from (emailFromField meta.email_from model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "Sync Settings" }
        [ Field meta.sync_elvanto (syncElvField meta.sync_elvanto model)
        ]
    ]


siteNameField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
siteNameField meta_ model =
    FV.simpleTextField meta_
        (Just model.site_name)
        (FormMsg << SiteConfigFormMsg << UpdateSiteNameField model)


smsLimitField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
smsLimitField meta_ model =
    FV.simpleIntField meta_
        (Just model.sms_char_limit)
        (FormMsg << SiteConfigFormMsg << UpdateSmsCharLimitField model)


smsRollingExpireField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
smsRollingExpireField meta_ model =
    FV.simpleIntField meta_
        model.sms_rolling_expiration_days
        (FormMsg << SiteConfigFormMsg << UpdateRollingExpiration model)


defaultPrefixField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
defaultPrefixField meta_ model =
    FV.simpleTextField meta_
        (Just model.default_number_prefix)
        (FormMsg << SiteConfigFormMsg << UpdateDefaultPrefixField model)


allRepliesField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
allRepliesField meta_ model =
    FV.checkboxField meta_
        (Just model)
        .disable_all_replies
        (msgOrNope (FormMsg << SiteConfigFormMsg << UpdateDisableRepliesField))


msgOrNope : (a -> Msg) -> Maybe a -> Msg
msgOrNope msg maybeRec =
    case maybeRec of
        Nothing ->
            Nope

        Just rec ->
            msg rec


emailLoginField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailLoginField meta_ model =
    FV.checkboxField meta_
        (Just model)
        .disable_email_login_form
        (msgOrNope (FormMsg << SiteConfigFormMsg << UpdateDisableLoginEmailField))


officeEmailField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
officeEmailField meta_ model =
    FV.simpleTextField meta_
        (Just model.office_email)
        (FormMsg << SiteConfigFormMsg << UpdateOfficeEmailField model)


autoNewGroupsField : RL.RemoteList RecipientGroup -> FieldMeta -> SiteConfigFormModel -> List (Html Msg)
autoNewGroupsField groups meta_ model =
    FV.multiSelectField meta_
        (FV.MultiSelectField
            groups
            (Just model.auto_add_new_groups)
            (Just model.auto_add_new_groups)
            model.groupsFilter
            (FormMsg << SiteConfigFormMsg << UpdateGroupsFilter model)
            (groupView model)
            (groupLabelView model)
        )


smsExpirationDateField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
smsExpirationDateField meta_ model =
    FV.dateField (updateExpDate model) meta_ model.datePickerSmsExpiredState model.sms_expiration_date


updateExpDate : SiteConfigFormModel -> DateTimePicker.State -> Maybe Date.Date -> Msg
updateExpDate model state maybeDate =
    FormMsg <| SiteConfigFormMsg <| UpdateSmsExpiredDate model state maybeDate


groupLabelView : SiteConfigFormModel -> Maybe (List Int) -> RecipientGroup -> Html Msg
groupLabelView model maybePks group =
    Html.div
        [ A.class "ui violet basic label"
        , A.style [ ( "user-select", "none" ) ]
        , E.onClick <| FormMsg <| SiteConfigFormMsg <| UpdateAutoAddGroupsField model group.pk
        ]
        [ Html.text group.name ]


groupView : SiteConfigFormModel -> Maybe (List Int) -> RecipientGroup -> Html Msg
groupView model maybeSelectedPks group =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ A.class "item", E.onClick <| FormMsg <| SiteConfigFormMsg <| UpdateAutoAddGroupsField model group.pk ]
        [ ( toString group.pk, groupViewHelper selectedPks group ) ]


groupViewHelper : List Int -> RecipientGroup -> Html Msg
groupViewHelper selectedPks group =
    Html.div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ FV.selectedIcon selectedPks group
        , Html.text group.name
        ]


slackField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
slackField meta_ model =
    FV.simpleTextField meta_
        (Just model.slack_url)
        (FormMsg << SiteConfigFormMsg << UpdateSlackUrlField model)


syncElvField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
syncElvField meta_ model =
    FV.checkboxField meta_
        (Just model)
        .sync_elvanto
        (msgOrNope (FormMsg << SiteConfigFormMsg << UpdateSyncElvantoField))


notAppField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
notAppField meta_ model =
    FV.longTextField
        10
        meta_
        (Just model.not_approved_msg)
        (FormMsg << SiteConfigFormMsg << UpdateNotApprovedField model)


emailHostField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailHostField meta_ model =
    FV.simpleTextField meta_
        (Just model.email_host)
        (FormMsg << SiteConfigFormMsg << UpdateEmailHostField model)


emailPortField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailPortField meta_ model =
    FV.simpleIntField meta_
        model.email_port
        (FormMsg << SiteConfigFormMsg << UpdateEmailPortField model)


emailUserField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailUserField meta_ model =
    FV.simpleTextField
        meta_
        (Just model.email_username)
        (FormMsg << SiteConfigFormMsg << UpdateEmailUserField model)


emailPassField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailPassField meta_ model =
    FV.simpleTextField
        meta_
        (Just model.email_password)
        (FormMsg << SiteConfigFormMsg << UpdateEmailPassField model)


emailFromField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailFromField meta_ model =
    FV.simpleTextField
        meta_
        (Just model.email_from)
        (FormMsg << SiteConfigFormMsg << UpdateEmailFromField model)
