module Pages.Forms.SiteConfig.Messages exposing (SiteConfigFormMsg(..))

import Date
import DateTimePicker
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)


type SiteConfigFormMsg
    = UpdateSiteNameField SiteConfigFormModel String
    | UpdateSmsCharLimitField SiteConfigFormModel String
    | UpdateDefaultPrefixField SiteConfigFormModel String
    | UpdateDisableRepliesField SiteConfigFormModel
    | UpdateDisableLoginEmailField SiteConfigFormModel
    | UpdateOfficeEmailField SiteConfigFormModel String
    | UpdateAutoAddGroupsField SiteConfigFormModel Int
    | UpdateSmsExpiredDate SiteConfigFormModel DateTimePicker.State (Maybe Date.Date)
    | UpdateSlackUrlField SiteConfigFormModel String
    | UpdateSyncElvantoField SiteConfigFormModel
    | UpdateNotApprovedField SiteConfigFormModel String
    | UpdateEmailHostField SiteConfigFormModel String
    | UpdateEmailPortField SiteConfigFormModel String
    | UpdateEmailUserField SiteConfigFormModel String
    | UpdateEmailPassField SiteConfigFormModel String
    | UpdateEmailFromField SiteConfigFormModel String
    | UpdateGroupsFilter SiteConfigFormModel String
