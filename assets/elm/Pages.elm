module Pages exposing (Page(..), initSendAdhoc, initSendGroup)

import Pages.FirstRun.Model exposing (FirstRunModel)
import Pages.Forms.Contact.Model exposing (ContactFormModel)
import Pages.Forms.ContactImport.Model exposing (ContactImportModel)
import Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel)
import Pages.Forms.Group.Model exposing (GroupFormModel)
import Pages.Forms.Keyword.Model exposing (KeywordFormModel)
import Pages.Forms.SendAdhoc.Model exposing (SendAdhocModel, initialSendAdhocModel)
import Pages.Forms.SendGroup.Model exposing (SendGroupModel, initialSendGroupModel)
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)
import Pages.Forms.UserProfile.Model exposing (UserProfileFormModel)
import Pages.GroupComposer.Model exposing (GroupComposerModel)


type Page
    = Home
    | AccessDenied
    | ContactForm ContactFormModel (Maybe Int)
    | CreateAllGroup String
    | Curator
    | ElvantoImport
    | Error404
    | FirstRun FirstRunModel
    | GroupComposer GroupComposerModel
    | GroupForm GroupFormModel (Maybe Int)
    | GroupTable IsArchive
    | InboundTable
    | KeyRespTable KeyRespTableModel IsArchive String
    | KeywordForm KeywordFormModel (Maybe String)
    | KeywordTable IsArchive
    | OutboundTable
    | RecipientTable IsArchive
    | ScheduledSmsTable
    | SendAdhoc SendAdhocModel
    | SendGroup SendGroupModel
    | UserProfileTable
    | Wall
    | SiteConfigForm (Maybe SiteConfigFormModel)
    | DefaultResponsesForm (Maybe DefaultResponsesFormModel)
    | Usage
    | UserProfileForm UserProfileFormModel Int
    | Help
    | ContactImport ContactImportModel
    | ApiSetup (Maybe String)


type alias IsArchive =
    Bool


type alias KeyRespTableModel =
    Bool


initSendAdhoc : Maybe String -> Maybe (List Int) -> Page
initSendAdhoc content pks =
    SendAdhoc <| initialSendAdhocModel content pks


initSendGroup : Maybe String -> Maybe Int -> Page
initSendGroup content pk =
    SendGroup <| initialSendGroupModel content pk
