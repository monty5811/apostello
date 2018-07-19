module Pages exposing (Page(..), initSendAdhoc, initSendGroup)

import Pages.Debug as DG
import Pages.DeletePanel as DP
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SendAdhoc as SAF
import Pages.Forms.SendGroup as SGF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UP
import Pages.GroupComposer as GC


type Page
    = Home
    | AccessDenied
    | ContactForm CF.Model (Maybe Int)
    | CreateAllGroup String
    | Curator
    | ElvantoImport
    | Error404
    | FirstRun FR.Model
    | Debug DG.Model
    | GroupComposer GC.Model
    | GroupForm GF.Model (Maybe Int)
    | GroupTable IsArchive
    | InboundTable
    | KeyRespTable Bool IsArchive String
    | KeywordForm KF.Model (Maybe String)
    | KeywordTable IsArchive
    | OutboundTable
    | RecipientTable IsArchive
    | ScheduledSmsTable
    | SendAdhoc SAF.Model
    | SendGroup SGF.Model
    | UserProfileTable
    | Wall
    | SiteConfigForm (Maybe SCF.Model)
    | DefaultResponsesForm (Maybe DRF.Model)
    | Usage
    | UserProfileForm UP.Model Int
    | Help
    | ContactImport CI.Model
    | ApiSetup (Maybe String)
    | DeletePanel DP.Model


type alias IsArchive =
    Bool


initSendAdhoc : Maybe String -> Maybe (List Int) -> Page
initSendAdhoc content pks =
    SendAdhoc <| SAF.initialModel content pks


initSendGroup : Maybe String -> Maybe Int -> Page
initSendGroup content pk =
    SendGroup <| SGF.initialModel content pk
