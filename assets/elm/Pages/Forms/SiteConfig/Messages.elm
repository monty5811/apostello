module Pages.Forms.SiteConfig.Messages exposing (SiteConfigFormMsg(..))

import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)


type SiteConfigFormMsg
    = UpdateSiteNameField SiteConfigFormModel String
    | UpdateSmsCharLimitField SiteConfigFormModel String
    | UpdateDefaultPrefixField SiteConfigFormModel String
    | UpdateDisableRepliesField SiteConfigFormModel
    | UpdateDisableLoginEmailField SiteConfigFormModel
    | UpdateOfficeEmailField SiteConfigFormModel String
    | UpdateAutoAddGroupsField SiteConfigFormModel Int
    | UpdateSlackUrlField SiteConfigFormModel String
    | UpdateSyncElvantoField SiteConfigFormModel
    | UpdateNotApprovedField SiteConfigFormModel String
    | UpdateEmailHostField SiteConfigFormModel String
    | UpdateEmailPortField SiteConfigFormModel String
    | UpdateEmailUserField SiteConfigFormModel String
    | UpdateEmailPassField SiteConfigFormModel String
    | UpdateEmailFromField SiteConfigFormModel String
    | UpdateGroupsFilter SiteConfigFormModel String
