module Pages exposing (Page(..), FabOnlyPage(..))


type Page
    = Home
    | OutboundTable
    | InboundTable
    | GroupTable IsArchive
    | GroupComposer
    | RecipientTable IsArchive
    | KeywordTable IsArchive
    | ElvantoImport
    | Wall
    | Curator
    | UserProfileTable
    | ScheduledSmsTable
    | KeyRespTable IsArchive String
    | FirstRun
    | AccessDenied
    | SendAdhoc (Maybe String) (Maybe (List Int))
    | SendGroup (Maybe String) (Maybe Int)
    | Error404
    | EditGroup Int
    | EditContact Int
    | FabOnlyPage FabOnlyPage


type FabOnlyPage
    = Help
    | NewGroup
    | CreateAllGroup
    | NewContact
    | NewKeyword
    | EditKeyword String
    | ContactImport
    | ApiSetup
    | EditUserProfile Int
    | EditSiteConfig
    | EditResponses


type alias IsArchive =
    Bool
