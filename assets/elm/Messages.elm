module Messages exposing (..)

import FilteringTable as FT
import Http
import Navigation
import Notification as Notif
import PageVisibility
import Pages.ApiSetup as AS
import Pages.Debug as DG
import Pages.ElvantoImport as EI
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAG
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SendAdhoc as SAF
import Pages.Forms.SendGroup as SGF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UP
import Pages.GroupComposer as GC
import Pages.KeyRespTable as KRT
import Store.Messages exposing (StoreMsg)
import Time
import WebPush


-- MESSAGES


type Msg
    = StoreMsg StoreMsg
    | UrlChange Navigation.Location
    | NewUrl String
    | FormMsg FormMsg
    | TableMsg FT.Msg
    | ElvantoMsg EI.Msg
    | GroupComposerMsg GC.Msg
    | KeyRespTableMsg KRT.Msg
    | FirstRunMsg FR.Msg
    | DebugMsg DG.Msg
    | SidePanelMsg SidePanelMsg
    | ApiSetupMsg AS.Msg
    | WebPushMsg WebPush.Msg
    | NotificationMsg Notif.Msg
    | CurrentTime Time.Time
    | Nope
    | ToggleMenu
    | KeyPressed Int
    | VisibilityChange PageVisibility.Visibility


type SidePanelMsg
    = ArchiveItem String String Bool
    | ReceiveArchiveResp String (Result Http.Error Bool)


type FormMsg
    = PostKeywordForm
    | PostContactForm Bool Bool
    | PostContactImportForm
    | PostCreateAllGroupForm
    | PostDefaultRespForm
    | PostGroupForm
    | PostSendAdhocForm
    | PostSendGroupForm
    | PostSiteConfigForm
    | PostUserProfileForm
    | ReceiveFormResp (List (Cmd Msg)) (Result Http.Error { body : String, code : Int })
    | GroupFormMsg GF.Msg
    | ContactFormMsg CF.Msg
    | KeywordFormMsg KF.Msg
    | UserProfileFormMsg UP.Msg
    | SiteConfigFormMsg SCF.Msg
    | DefaultResponsesFormMsg DRF.Msg
    | CreateAllGroupMsg CAG.Msg
    | ContactImportMsg CI.Msg
    | ReceiveSiteConfigFormModel (Result Http.Error SCF.Model)
    | SendAdhocMsg SAF.Msg
    | SendGroupMsg SGF.Msg
