module Pages exposing (FabOnlyPage(..), Page(..), initSendAdhoc, initSendGroup)

import Pages.ContactForm.Model exposing (ContactFormModel)
import Pages.FirstRun.Model exposing (FirstRunModel)
import Pages.GroupComposer.Model exposing (GroupComposerModel)
import Pages.GroupForm.Model exposing (GroupFormModel)
import Pages.KeywordForm.Model exposing (KeywordFormModel)
import Pages.SendAdhocForm.Model exposing (SendAdhocModel, initialSendAdhocModel)
import Pages.SendGroupForm.Model exposing (SendGroupModel, initialSendGroupModel)
import Pages.SiteConfigForm.Model exposing (SiteConfigFormModel)


type Page
    = Home
    | AccessDenied
    | ContactForm ContactFormModel (Maybe Int)
    | Curator
    | ElvantoImport
    | Error404
    | FabOnlyPage FabOnlyPage
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


type FabOnlyPage
    = Help
    | CreateAllGroup
    | ContactImport
    | ApiSetup
    | EditUserProfile Int
    | EditResponses


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
