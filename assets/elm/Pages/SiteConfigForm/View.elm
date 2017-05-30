module Pages.SiteConfigForm.View exposing (view)

import Data.RecipientGroup exposing (RecipientGroup)
import Data.Store as Store
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View as FV
import Html exposing (Html, div, text)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Messages exposing (FormMsg(PostSiteConfigForm), Msg(FormMsg, Nope, SiteConfigFormMsg))
import Pages.SiteConfigForm.Messages exposing (SiteConfigFormMsg(..))
import Pages.SiteConfigForm.Meta exposing (meta)
import Pages.SiteConfigForm.Model exposing (SiteConfigFormModel)


-- Main view


view : Store.DataStore -> Maybe SiteConfigFormModel -> FormStatus -> Html Msg
view dataStore maybeModel status =
    case maybeModel of
        Nothing ->
            div [ A.class "ui active loader" ] []

        Just model ->
            let
                groups =
                    Store.filterArchived False dataStore.groups

                fields =
                    [ Field meta.site_name (siteNameField meta.site_name model)
                    , Field meta.sms_char_limit (smsLimitField meta.sms_char_limit model)
                    , Field meta.default_number_prefix (defaultPrefixField meta.default_number_prefix model)
                    , Field meta.disable_all_replies (allRepliesField meta.disable_all_replies model)
                    , Field meta.disable_email_login_form (emailLoginField meta.disable_email_login_form model)
                    , Field meta.office_email (officeEmailField meta.office_email model)
                    , Field meta.auto_add_new_groups (autoNewGroupsField groups meta.auto_add_new_groups model)
                    , Field meta.slack_url (slackField meta.slack_url model)
                    , Field meta.sync_elvanto (syncElvField meta.sync_elvanto model)
                    , Field meta.not_approved_msg (notAppField meta.not_approved_msg model)
                    , Field meta.email_host (emailHostField meta.email_host model)
                    , Field meta.email_port (emailPortField meta.email_port model)
                    , Field meta.email_username (emailUserField meta.email_username model)
                    , Field meta.email_password (emailPassField meta.email_password model)
                    , Field meta.email_from (emailFromField meta.email_from model)
                    ]
            in
            FV.form status
                fields
                (FormMsg <| PostSiteConfigForm model)
                (FV.submitButton (Just model) False)


siteNameField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
siteNameField meta model =
    FV.simpleTextField meta
        (Just model.site_name)
        (SiteConfigFormMsg << UpdateSiteNameField model)


smsLimitField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
smsLimitField meta model =
    FV.simpleIntField meta
        (Just model.sms_char_limit)
        (SiteConfigFormMsg << UpdateSmsCharLimitField model)


defaultPrefixField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
defaultPrefixField meta model =
    FV.simpleTextField meta
        (Just model.default_number_prefix)
        (SiteConfigFormMsg << UpdateDefaultPrefixField model)


allRepliesField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
allRepliesField meta model =
    FV.checkboxField meta
        (Just model)
        .disable_all_replies
        (msgOrNope (SiteConfigFormMsg << UpdateDisableRepliesField))


msgOrNope : (a -> Msg) -> Maybe a -> Msg
msgOrNope msg maybeRec =
    case maybeRec of
        Nothing ->
            Nope

        Just rec ->
            msg rec


emailLoginField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailLoginField meta model =
    FV.checkboxField meta
        (Just model)
        .disable_email_login_form
        (msgOrNope (SiteConfigFormMsg << UpdateDisableLoginEmailField))


officeEmailField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
officeEmailField meta model =
    FV.simpleTextField meta
        (Just model.office_email)
        (SiteConfigFormMsg << UpdateOfficeEmailField model)


autoNewGroupsField : Store.RemoteList RecipientGroup -> FieldMeta -> SiteConfigFormModel -> List (Html Msg)
autoNewGroupsField groups meta model =
    FV.multiSelectField meta
        (FV.MultiSelectField
            groups
            (Just model.auto_add_new_groups)
            (Just model.auto_add_new_groups)
            model.groupsFilter
            (SiteConfigFormMsg << UpdateGroupsFilter model)
            (groupView model)
        )


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
        [ A.class "item", E.onClick <| SiteConfigFormMsg <| UpdateAutoAddGroupsField model group.pk ]
        [ ( toString group.pk, groupViewHelper selectedPks group ) ]


groupViewHelper : List Int -> RecipientGroup -> Html Msg
groupViewHelper selectedPks group =
    div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ FV.selectedIcon selectedPks group
        , text group.name
        ]


slackField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
slackField meta model =
    FV.simpleTextField meta
        (Just model.slack_url)
        (SiteConfigFormMsg << UpdateSlackUrlField model)


syncElvField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
syncElvField meta model =
    FV.checkboxField meta
        (Just model)
        .sync_elvanto
        (msgOrNope (SiteConfigFormMsg << UpdateSyncElvantoField))


notAppField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
notAppField meta model =
    FV.longTextField
        10
        meta
        (Just model.not_approved_msg)
        (SiteConfigFormMsg << UpdateNotApprovedField model)


emailHostField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailHostField meta model =
    FV.simpleTextField meta
        (Just model.email_host)
        (SiteConfigFormMsg << UpdateEmailHostField model)


emailPortField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailPortField meta model =
    FV.simpleIntField meta
        model.email_port
        (SiteConfigFormMsg << UpdateEmailPortField model)


emailUserField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailUserField meta model =
    FV.simpleTextField
        meta
        (Just model.email_username)
        (SiteConfigFormMsg << UpdateEmailUserField model)


emailPassField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailPassField meta model =
    FV.simpleTextField
        meta
        (Just model.email_password)
        (SiteConfigFormMsg << UpdateEmailPassField model)


emailFromField : FieldMeta -> SiteConfigFormModel -> List (Html Msg)
emailFromField meta model =
    FV.simpleTextField
        meta
        (Just model.email_from)
        (SiteConfigFormMsg << UpdateEmailFromField model)
