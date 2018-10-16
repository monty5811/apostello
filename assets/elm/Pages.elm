module Pages exposing (Page(..), initSendAdhoc, initSendGroup)

import Pages.Curator as C
import Pages.Debug as DG
import Pages.DeletePanel as DP
import Pages.ElvantoImport as EI
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAGF
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SendAdhoc as SAF
import Pages.Forms.SendGroup as SGF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UP
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.InboundTable as IT
import Pages.KeyRespTable as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.UserProfileTable as UPT


type Page
    = Home
    | AccessDenied
    | ContactForm CF.Model
    | CreateAllGroup CAGF.Model
    | Curator C.Model
    | ElvantoImport EI.Model
    | Error404
    | FirstRun FR.Model
    | Debug DG.Model
    | GroupComposer GC.Model
    | GroupForm GF.Model
    | GroupTable GT.Model IsArchive
    | InboundTable IT.Model
    | KeyRespTable KRT.Model IsArchive String
    | KeywordForm KF.Model
    | KeywordTable KT.Model IsArchive
    | OutboundTable OT.Model
    | RecipientTable RT.Model IsArchive
    | ScheduledSmsTable SST.Model
    | SendAdhoc SAF.Model
    | SendGroup SGF.Model
    | UserProfileTable UPT.Model
    | Wall
    | SiteConfigForm SCF.Model
    | DefaultResponsesForm DRF.Model
    | Usage
    | UserProfileForm UP.Model
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
