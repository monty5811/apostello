module Models exposing (..)

import Date
import Regex
import Set exposing (Set)
import Time


-- Main Model


type alias Model =
    { page : Page
    , loadingStatus : LoadingStatus
    , filterRegex : Regex.Regex
    , csrftoken : CSRFToken
    , dataUrl : String
    , outboundTable : OutboundTableModel
    , inboundTable : InboundTableModel
    , groupTable : GroupTableModel
    , groupComposer : GroupComposerModel
    , groupSelect : GroupMemberSelectModel
    , recipientTable : RecipientTableModel
    , keywordTable : KeywordTableModel
    , wall : WallModel
    , elvantoImport : ElvantoImportModel
    , userProfileTable : UserProfileTableModel
    , scheduledSmsTable : ScheduledSmsTableModel
    , keyRespTable : KeyRespTableModel
    , firstRun : FirstRunModel
    , fabModel : FabModel
    , notifications : List Notification
    , currentTime : Time.Time
    }


initialModel : CSRFToken -> Page -> String -> Maybe FabFlags -> Model
initialModel csrftoken page incomingUrl fabFlags =
    { page = page
    , loadingStatus = initialLoadingStatus page
    , filterRegex = Regex.regex ""
    , csrftoken = csrftoken
    , outboundTable = initialOutboundTableModel
    , inboundTable = initialInboundTableModel
    , groupTable = initialGroupTableModel
    , groupComposer = initialGroupComposerModel
    , groupSelect = initialGroupMemberSelectModel
    , recipientTable = initialRecipientTableModel
    , keywordTable = initialKeywordTableModel
    , wall = initialWallModel
    , elvantoImport = initialElvantoImportModel
    , userProfileTable = initialUserProfileTableModel
    , scheduledSmsTable = initialScheduledSmsTable
    , keyRespTable = initialKeyRespModel
    , firstRun = initialFirstRunModel
    , fabModel = initialFabModel fabFlags
    , notifications = []
    , dataUrl = incomingUrl
    , currentTime = 0
    }


initialLoadingStatus : Page -> LoadingStatus
initialLoadingStatus page =
    case page of
        FirstRun ->
            Finished

        Fab ->
            Finished

        _ ->
            NotAsked


type alias Flags =
    { pageId : String
    , csrftoken : CSRFToken
    , dataUrl : String
    , fabData : Maybe FabFlags
    }


type alias Notification =
    { type_ : NotificationType
    , text : String
    , id : Int
    , created : Time.Time
    }


type NotificationType
    = InfoNotification
    | SuccessNotification
    | WarningNotification
    | ErrorNotification


type alias FabFlags =
    { pageLinks : List PageLink
    , archiveButton : Maybe ArchiveButton
    }


type Page
    = OutboundTable
    | InboundTable
    | GroupTable
    | GroupComposer
    | GroupSelect
    | RecipientTable
    | KeywordTable
    | ElvantoImport
    | Wall
    | Curator
    | UserProfileTable
    | ScheduledSmsTable
    | KeyRespTable
    | FirstRun
    | Fab


type LoadingStatus
    = NotAsked
    | WaitingForFirst
    | WaitingForSubsequent
    | Finished


type alias CSRFToken =
    String


type alias FabModel =
    { pageLinks : List PageLink
    , archiveButton : Maybe ArchiveButton
    , fabState : FabState
    }


initialFabModel : Maybe FabFlags -> FabModel
initialFabModel flags =
    case flags of
        Nothing ->
            { pageLinks = []
            , archiveButton = Nothing
            , fabState = MenuHidden
            }

        Just f ->
            { pageLinks = f.pageLinks
            , archiveButton = f.archiveButton
            , fabState = MenuHidden
            }


type FabState
    = MenuHidden
    | MenuVisible


type alias PageLink =
    { url : String
    , iconType : String
    , linkText : String
    }


type alias ArchiveButton =
    { postUrl : String
    , isArchived : Bool
    , redirectUrl : String
    }


type alias FirstRunModel =
    { adminEmail : String
    , adminPass1 : String
    , adminPass2 : String
    , adminFormStatus : FormStatus
    , testEmailTo : String
    , testEmailBody : String
    , testEmailFormStatus : FormStatus
    , testSmsTo : String
    , testSmsBody : String
    , testSmsFormStatus : FormStatus
    }


initialFirstRunModel : FirstRunModel
initialFirstRunModel =
    { adminEmail = ""
    , adminPass1 = ""
    , adminPass2 = ""
    , adminFormStatus = NoAction
    , testEmailTo = ""
    , testEmailBody = ""
    , testEmailFormStatus = NoAction
    , testSmsTo = ""
    , testSmsBody = ""
    , testSmsFormStatus = NoAction
    }


type FormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String


type alias ElvantoImportModel =
    { groups : ElvantoGroups }


initialElvantoImportModel : ElvantoImportModel
initialElvantoImportModel =
    { groups = [] }


type alias InboundTableModel =
    { sms : SmsInbounds
    }


initialInboundTableModel : InboundTableModel
initialInboundTableModel =
    { sms = []
    }


type alias GroupMemberSelectModel =
    { pk : Int
    , description : String
    , members : List RecipientSimple
    , nonmembers : List RecipientSimple
    , url : String
    , membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    }


initialGroupMemberSelectModel : GroupMemberSelectModel
initialGroupMemberSelectModel =
    { pk = 0
    , description = ""
    , members = []
    , nonmembers = []
    , url = "#"
    , membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    }


type alias WallModel =
    { sms : List SmsInboundSimple
    }


initialWallModel : WallModel
initialWallModel =
    { sms = []
    }


type alias UserProfileTableModel =
    { userprofiles : List UserProfile }


initialUserProfileTableModel : UserProfileTableModel
initialUserProfileTableModel =
    { userprofiles = [] }


type alias KeywordTableModel =
    { keywords : List Keyword }


initialKeywordTableModel : KeywordTableModel
initialKeywordTableModel =
    { keywords = [] }


type alias RecipientTableModel =
    { recipients : List Recipient }


initialRecipientTableModel : RecipientTableModel
initialRecipientTableModel =
    { recipients = [] }


type alias OutboundTableModel =
    { sms : SmsOutbounds
    }


initialOutboundTableModel : OutboundTableModel
initialOutboundTableModel =
    { sms = [] }


type alias GroupTableModel =
    { groups : List RecipientGroup }


initialGroupTableModel : GroupTableModel
initialGroupTableModel =
    { groups = [] }


type alias GroupComposerModel =
    { groups : Groups
    , people : PeopleSimple
    , query : Maybe String
    }


initialGroupComposerModel : GroupComposerModel
initialGroupComposerModel =
    { groups = []
    , people = []
    , query = Nothing
    }


type QueryOp
    = Union
    | Intersect
    | Diff
    | OpenBracket
    | CloseBracket
    | G (Set Int)
    | NoOp


type alias Query =
    List QueryOp


type alias ParenLoc =
    { open : Maybe Int
    , close : Maybe Int
    }


type alias ScheduledSmsTableModel =
    { sms : List QueuedSms }


initialScheduledSmsTable : ScheduledSmsTableModel
initialScheduledSmsTable =
    { sms = [] }


type alias KeyRespTableModel =
    { sms : SmsInbounds }


initialKeyRespModel : KeyRespTableModel
initialKeyRespModel =
    { sms = [] }



-- Apostello Models


type alias ApostelloResponse a =
    { next : Maybe String
    , previous : Maybe String
    , count : Int
    , results : List a
    }


type alias GroupPk =
    Int


type alias PersonPk =
    Int


type alias PeopleSimple =
    List RecipientSimple


type alias Groups =
    List RecipientGroup


nullGroup : RecipientGroup
nullGroup =
    RecipientGroup "" 0 "" [] [] "" "" False


type alias Keyword =
    { keyword : String
    , pk : Int
    , description : String
    , current_response : String
    , is_live : Bool
    , url : String
    , responses_url : String
    , num_replies : String
    , num_archived_replies : String
    , is_archived : Bool
    }


type alias QueuedSms =
    { pk : Int
    , time_to_send : Date.Date
    , time_to_send_formatted : String
    , sent : Bool
    , failed : Bool
    , content : String
    , recipient : Recipient
    , recipient_group : Maybe RecipientGroup
    , sent_by : String
    }


type alias RecipientGroup =
    { name : String
    , pk : Int
    , description : String
    , members : List RecipientSimple
    , nonmembers : List RecipientSimple
    , cost : String
    , url : String
    , is_archived : Bool
    }


type alias Recipient =
    { first_name : String
    , last_name : String
    , pk : Int
    , url : String
    , full_name : String
    , number : String
    , is_archived : Bool
    , is_blocking : Bool
    , do_not_reply : Bool
    , last_sms : Maybe SmsInboundSimple
    }


type alias RecipientSimple =
    { full_name : String
    , pk : Int
    }


type alias SmsInbound =
    { sid : String
    , pk : Int
    , sender_name : String
    , content : String
    , time_received : String
    , dealt_with : Bool
    , is_archived : Bool
    , display_on_wall : Bool
    , matched_keyword : String
    , matched_colour : String
    , matched_link : String
    , sender_url : Maybe String
    , sender_pk : Maybe Int
    }


type alias SmsInbounds =
    List SmsInbound


type alias SmsInboundSimple =
    { pk : Int
    , content : String
    , time_received : String
    , is_archived : Bool
    , display_on_wall : Bool
    , matched_keyword : String
    }


type alias UserProfile =
    { pk : Int
    , user : User
    , url : String
    , approved : Bool
    , can_see_groups : Bool
    , can_see_contact_names : Bool
    , can_see_keywords : Bool
    , can_see_outgoing : Bool
    , can_see_incoming : Bool
    , can_send_sms : Bool
    , can_see_contact_nums : Bool
    , can_import : Bool
    , can_archive : Bool
    }


type alias User =
    { email : String
    , username : String
    }


type alias SmsOutbound =
    { content : String
    , pk : Int
    , time_sent : String
    , sent_by : String
    , recipient : Maybe RecipientSimple
    }


type alias SmsOutbounds =
    List SmsOutbound


type alias ElvantoGroup =
    { name : String
    , pk : Int
    , sync : Bool
    , last_synced : String
    }


type alias ElvantoGroups =
    List ElvantoGroup


type alias FirstRunResp =
    { status : String
    , error : String
    }
