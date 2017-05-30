module Messages exposing (..)

import Data.Keyword exposing (Keyword)
import Data.Recipient exposing (Recipient)
import Data.RecipientGroup exposing (RecipientGroup)
import Data.Request exposing (StoreMsg)
import Http
import Navigation
import Pages.ContactForm.Messages exposing (ContactFormMsg)
import Pages.ContactForm.Model exposing (ContactFormModel)
import Pages.ElvantoImport.Messages exposing (ElvantoMsg)
import Pages.FirstRun.Messages exposing (FirstRunMsg)
import Pages.GroupComposer.Messages exposing (GroupComposerMsg)
import Pages.GroupForm.Messages exposing (GroupFormMsg)
import Pages.GroupForm.Model exposing (GroupFormModel)
import Pages.GroupTable.Messages exposing (GroupTableMsg)
import Pages.InboundTable.Messages exposing (InboundTableMsg)
import Pages.KeyRespTable.Messages exposing (KeyRespTableMsg)
import Pages.KeywordForm.Messages exposing (KeywordFormMsg)
import Pages.KeywordForm.Model exposing (KeywordFormModel)
import Pages.KeywordTable.Messages exposing (KeywordTableMsg)
import Pages.RecipientTable.Messages exposing (RecipientTableMsg)
import Pages.ScheduledSmsTable.Messages exposing (ScheduledSmsTableMsg)
import Pages.SendAdhocForm.Messages exposing (SendAdhocMsg)
import Pages.SendAdhocForm.Model exposing (SendAdhocModel)
import Pages.SendGroupForm.Messages exposing (SendGroupMsg)
import Pages.SendGroupForm.Model exposing (SendGroupModel)
import Pages.SiteConfigForm.Messages exposing (SiteConfigFormMsg)
import Pages.SiteConfigForm.Model exposing (SiteConfigFormModel)
import Pages.UserProfileTable.Messages exposing (UserProfileTableMsg)
import Pages.Wall.Messages exposing (WallMsg)
import Time


-- MESSAGES


type Msg
    = StoreMsg StoreMsg
    | UrlChange Navigation.Location
    | NewUrl String
    | FormMsg FormMsg
    | UpdateTableFilter String
    | ElvantoMsg ElvantoMsg
    | InboundTableMsg InboundTableMsg
    | RecipientTableMsg RecipientTableMsg
    | KeywordTableMsg KeywordTableMsg
    | GroupTableMsg GroupTableMsg
    | GroupComposerMsg GroupComposerMsg
    | GroupFormMsg GroupFormMsg
    | ContactFormMsg ContactFormMsg
    | KeywordFormMsg KeywordFormMsg
    | WallMsg WallMsg
    | UserProfileTableMsg UserProfileTableMsg
    | ScheduledSmsTableMsg ScheduledSmsTableMsg
    | KeyRespTableMsg KeyRespTableMsg
    | FirstRunMsg FirstRunMsg
    | SendAdhocMsg SendAdhocMsg
    | SendGroupMsg SendGroupMsg
    | SiteConfigFormMsg SiteConfigFormMsg
    | FabMsg FabMsg
    | NotificationMsg NotificationMsg
    | CurrentTime Time.Time
    | ReceiveSiteConfigFormModel (Result Http.Error SiteConfigFormModel)
    | Nope


type NotificationMsg
    = RemoveNotification Int


type FabMsg
    = ArchiveItem String String Bool
    | ReceiveArchiveResp String (Result Http.Error Bool)
    | ToggleFabView


type FormMsg
    = PostKeywordForm KeywordFormModel (Maybe Keyword)
    | PostContactForm ContactFormModel (Maybe Recipient)
    | PostGroupForm GroupFormModel (Maybe RecipientGroup)
    | PostAdhocForm SendAdhocModel
    | PostSGForm SendGroupModel
    | PostSiteConfigForm SiteConfigFormModel
    | ReceiveFormResp (List (Cmd Msg)) (Result Http.Error { body : String, code : Int })
