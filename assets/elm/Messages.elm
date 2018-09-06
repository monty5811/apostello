module Messages exposing (ActionsPanelMsg(..), Msg(..))

import Http
import Navigation
import Notification as Notif
import PageVisibility
import Pages.ApiSetup as AS
import Pages.Curator as C
import Pages.Debug as DG
import Pages.DeletePanel as DP
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
import Pages.Forms.UserProfile as UPF
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.InboundTable as IT
import Pages.KeyRespTable as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.UserProfileTable as UPT
import Store.Messages
import Time


-- MESSAGES


type Msg
    = StoreMsg Store.Messages.Msg
      -- Url
    | NewUrl String
    | UrlChange Navigation.Location
      -- Global
    | CurrentTime Time.Time
    | Nope
    | ScrollToId String
    | VisibilityChange PageVisibility.Visibility
      -- Fragments
    | ActionsPanelMsg ActionsPanelMsg
    | NotificationMsg Notif.Msg
      -- Pages
    | ApiSetupMsg AS.Msg
    | ContactFormMsg CF.Msg
    | ContactImportMsg CI.Msg
    | CreateAllGroupMsg CAG.Msg
    | CuratorMsg C.Msg
    | DebugMsg DG.Msg
    | DefaultResponsesFormMsg DRF.Msg
    | DeletePanelMsg DP.Msg
    | ElvantoMsg EI.Msg
    | FirstRunMsg FR.Msg
    | GroupComposerMsg GC.Msg
    | GroupFormMsg GF.Msg
    | GroupTableMsg GT.Msg
    | InboundTableMsg IT.Msg
    | KeyRespTableMsg KRT.Msg
    | KeywordFormMsg KF.Msg
    | KeywordTableMsg KT.Msg
    | OutboundTableMsg OT.Msg
    | RecipientTableMsg RT.Msg
    | ScheduledSmsTableMsg SST.Msg
    | SendAdhocMsg SAF.Msg
    | SendGroupMsg SGF.Msg
    | SiteConfigFormMsg SCF.Msg
    | UserProfileFormMsg UPF.Msg
    | UserProfileTableMsg UPT.Msg


type ActionsPanelMsg
    = ArchiveItem String String Bool
    | ReceiveArchiveResp String (Result Http.Error Bool)
