module Messages exposing (..)

import FilteringTable.Messages exposing (TableMsg)
import Http
import Navigation
import Pages.ApiSetup.Messages exposing (ApiSetupMsg)
import Pages.ElvantoImport.Messages exposing (ElvantoMsg)
import Pages.FirstRun.Messages exposing (FirstRunMsg)
import Pages.Forms.Contact.Messages exposing (ContactFormMsg)
import Pages.Forms.ContactImport.Messages exposing (ContactImportMsg)
import Pages.Forms.CreateAllGroup.Messages exposing (CreateAllGroupMsg)
import Pages.Forms.DefaultResponses.Messages exposing (DefaultResponsesFormMsg)
import Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel)
import Pages.Forms.Group.Messages exposing (GroupFormMsg)
import Pages.Forms.Keyword.Messages exposing (KeywordFormMsg)
import Pages.Forms.SendAdhoc.Messages exposing (SendAdhocMsg)
import Pages.Forms.SendGroup.Messages exposing (SendGroupMsg)
import Pages.Forms.SiteConfig.Messages exposing (SiteConfigFormMsg)
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)
import Pages.Forms.UserProfile.Messages exposing (UserProfileFormMsg)
import Pages.GroupComposer.Messages exposing (GroupComposerMsg)
import Pages.KeyRespTable.Messages exposing (KeyRespTableMsg)
import Store.Messages exposing (StoreMsg)
import Time


-- MESSAGES


type Msg
    = StoreMsg StoreMsg
    | UrlChange Navigation.Location
    | NewUrl String
    | FormMsg FormMsg
    | TableMsg TableMsg
    | ElvantoMsg ElvantoMsg
    | GroupComposerMsg GroupComposerMsg
    | KeyRespTableMsg KeyRespTableMsg
    | FirstRunMsg FirstRunMsg
    | FabMsg FabMsg
    | ApiSetupMsg ApiSetupMsg
    | NotificationMsg NotificationMsg
    | CurrentTime Time.Time
    | Nope


type NotificationMsg
    = RemoveNotification Int


type FabMsg
    = ArchiveItem String String Bool
    | ReceiveArchiveResp String (Result Http.Error Bool)
    | ToggleFabView


type FormMsg
    = PostForm (Cmd Msg)
    | ReceiveFormResp (List (Cmd Msg)) (Result Http.Error { body : String, code : Int })
    | GroupFormMsg GroupFormMsg
    | ContactFormMsg ContactFormMsg
    | KeywordFormMsg KeywordFormMsg
    | UserProfileFormMsg UserProfileFormMsg
    | SiteConfigFormMsg SiteConfigFormMsg
    | DefaultResponsesFormMsg DefaultResponsesFormMsg
    | CreateAllGroupMsg CreateAllGroupMsg
    | ContactImportMsg ContactImportMsg
    | ReceiveSiteConfigFormModel (Result Http.Error SiteConfigFormModel)
    | ReceiveDefaultResponsesFormModel (Result Http.Error DefaultResponsesFormModel)
    | SendAdhocMsg SendAdhocMsg
    | SendGroupMsg SendGroupMsg
