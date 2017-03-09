module Models exposing (..)

import Date
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (optional, required, decode, requiredAt)
import Regex
import Set exposing (Set)
import Time


-- Main Model


type alias Model =
    { page : Page
    , loadingStatus : LoadingStatus
    , filterRegex : Regex.Regex
    , settings : Settings
    , dataStore : DataStore
    , groupComposer : GroupComposerModel
    , groupSelect : GroupMemberSelectModel
    , keyRespTable : Bool
    , firstRun : FirstRunModel
    , sendAdhoc : SendAdhocModel
    , sendGroup : SendGroupModel
    , fabModel : FabModel
    , notifications : List Notification
    , currentTime : Time.Time
    }


initialModel : Settings -> String -> Page -> Model
initialModel settings dataStoreCache page =
    { page = page
    , loadingStatus = NoRequestSent
    , filterRegex = Regex.regex ""
    , settings = settings
    , dataStore = Result.withDefault emptyDataStore <| Decode.decodeString dataStoreDecoder dataStoreCache
    , groupComposer = initialGroupComposerModel
    , groupSelect = initialGroupMemberSelectModel
    , keyRespTable = False
    , firstRun = initialFirstRunModel
    , sendAdhoc = initialSendAdhocModel page
    , sendGroup = initialSendGroupModel page
    , fabModel = initialFabModel
    , notifications = []
    , currentTime = 0
    }


type alias Settings =
    { csrftoken : CSRFToken
    , userPerms : UserProfile
    , twilioSendingCost : Float
    , twilioFromNumber : String
    , smsCharLimit : Int
    , blockedKeywords : List String
    }


type RemoteDataType
    = IncomingSms
    | OutgoingSms
    | Contacts
    | Groups
    | Keywords
    | ScheduledSms
    | ElvantoGroups_
    | UserProfiles


type alias DataStore =
    { inboundSms : List SmsInbound
    , outboundSms : List SmsOutbound
    , elvantoGroups : List ElvantoGroup
    , userprofiles : List UserProfile
    , keywords : List Keyword
    , recipients : List Recipient
    , groups : List RecipientGroup
    , queuedSms : List QueuedSms
    }


emptyDataStore : DataStore
emptyDataStore =
    { inboundSms = []
    , outboundSms = []
    , elvantoGroups = []
    , userprofiles = []
    , keywords = []
    , recipients = []
    , groups = []
    , queuedSms = []
    }



--


type alias Flags =
    { settings : Settings
    , dataStoreCache : Maybe String
    }


type alias RawResponse =
    { body : String
    , next : Maybe String
    }


type alias Notification =
    { type_ : NotificationType
    , text : String
    }


type alias DjangoMessage =
    { type_ : String
    , text : String
    }


type alias SendAdhocFormResp =
    { messages : List DjangoMessage
    , errors : SendAdhocFormError
    }


type NotificationType
    = InfoNotification
    | SuccessNotification
    | WarningNotification
    | ErrorNotification


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


type LoadingStatus
    = NoRequestSent
    | WaitingForFirstResp
    | WaitingForPage
    | FinalPageReceived
    | WaitingOnRefresh
    | RespFailed String


type alias CSRFToken =
    String


initialFabModel : FabModel
initialFabModel =
    MenuHidden


type FabModel
    = MenuHidden
    | MenuVisible


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


type alias GroupMemberSelectModel =
    { pk : Int
    , membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    }


initialGroupMemberSelectModel : GroupMemberSelectModel
initialGroupMemberSelectModel =
    { pk = 0
    , membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    }


type alias GroupComposerModel =
    { query : Maybe String
    }


initialGroupComposerModel : GroupComposerModel
initialGroupComposerModel =
    { query = Nothing
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



-- Apostello Models


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
    RecipientGroup "" 0 "" [] [] 0 "" False


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
    , time_to_send : Maybe Date.Date
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
    , cost : Float
    , url : String
    , is_archived : Bool
    }


type alias Recipient =
    { first_name : String
    , last_name : String
    , pk : Int
    , url : String
    , full_name : String
    , is_archived : Bool
    , is_blocking : Bool
    , do_not_reply : Bool
    , last_sms : Maybe SmsInbound
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
    , time_received : Maybe Date.Date
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


type alias UserProfile =
    { pk : Int
    , user : User
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
    , is_staff : Bool
    , is_social : Bool
    }


type alias SmsOutbound =
    { content : String
    , pk : Int
    , time_sent : Maybe Date.Date
    , sent_by : String
    , recipient : Maybe RecipientSimple
    }


type alias SmsOutbounds =
    List SmsOutbound


type alias ElvantoGroup =
    { name : String
    , pk : Int
    , sync : Bool
    , last_synced : Maybe Date.Date
    }


type alias ElvantoGroups =
    List ElvantoGroup


type alias FirstRunResp =
    { status : String
    , error : String
    }


type alias SendAdhocModel =
    { content : String
    , selectedContacts : List Int
    , date : Maybe Date.Date
    , errors : SendAdhocFormError
    , status : FormStatus
    , modalOpen : Bool
    , adhocFilter : Regex.Regex
    , cost : Maybe Float
    }


type alias SendAdhocFormError =
    { recipients : List String
    , scheduled_time : List String
    , content : List String
    , all : List String
    }


initialSendAdhocModel : Page -> SendAdhocModel
initialSendAdhocModel page =
    let
        initialContent =
            case page of
                SendAdhoc urlContent _ ->
                    urlContent |> Maybe.withDefault ""

                _ ->
                    ""

        initialPks =
            case page of
                SendAdhoc _ pks ->
                    pks

                _ ->
                    Nothing
    in
        { content = initialContent
        , selectedContacts = Maybe.withDefault [] initialPks
        , date = Nothing
        , errors = { recipients = [], scheduled_time = [], content = [], all = [] }
        , status = NoAction
        , modalOpen = False
        , adhocFilter = Regex.regex ""
        , cost = Nothing
        }


type alias SendGroupModel =
    { content : String
    , date : Maybe Date.Date
    , errors : SendGroupFormError
    , status : FormStatus
    , modalOpen : Bool
    , selectedPk : Maybe Int
    , cost : Maybe Float
    , groupFilter : Regex.Regex
    }


type alias SendGroupFormError =
    { group : List String
    , scheduled_time : List String
    , content : List String
    , all : List String
    }


initialSendGroupModel : Page -> SendGroupModel
initialSendGroupModel page =
    let
        initialContent =
            case page of
                SendGroup urlContent _ ->
                    urlContent

                _ ->
                    Nothing

        initialSelectedGroup =
            case page of
                SendGroup _ pk ->
                    pk

                _ ->
                    Nothing
    in
        { content = Maybe.withDefault "" initialContent
        , selectedPk = initialSelectedGroup
        , date = Nothing
        , errors = { group = [], scheduled_time = [], content = [], all = [] }
        , status = NoAction
        , modalOpen = False
        , cost = Nothing
        , groupFilter = Regex.regex ""
        }


type alias SendGroupFormResp =
    { messages : List DjangoMessage
    , errors : SendGroupFormError
    }



-- Decoders


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True


dataFromResp : Decode.Decoder a -> RawResponse -> List a
dataFromResp decoder rawResp =
    rawResp.body
        |> Decode.decodeString (Decode.field "results" (Decode.list decoder))
        |> Result.withDefault []


itemFromResp : a -> Decode.Decoder a -> RawResponse -> a
itemFromResp defaultCallback decoder rawResp =
    rawResp.body
        |> Decode.decodeString decoder
        |> Result.withDefault defaultCallback


decodeFirstRunResp : Decode.Decoder FirstRunResp
decodeFirstRunResp =
    decode FirstRunResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


decodeSendAdhocFormResp : Decode.Decoder SendAdhocFormResp
decodeSendAdhocFormResp =
    decode SendAdhocFormResp
        |> required "messages" (Decode.list decodeDjangoMessage)
        |> required "errors" decodeSendAdhocFormError


decodeDjangoMessage : Decode.Decoder DjangoMessage
decodeDjangoMessage =
    decode DjangoMessage
        |> required "type_" Decode.string
        |> required "text" Decode.string


decodeSendAdhocFormError : Decode.Decoder SendAdhocFormError
decodeSendAdhocFormError =
    decode SendAdhocFormError
        |> optional "recipients" (Decode.list Decode.string) []
        |> optional "scheduled_time" (Decode.list Decode.string) []
        |> optional "content" (Decode.list Decode.string) []
        |> optional "__all__" (Decode.list Decode.string) []


decodeSendGroupFormResp : Decode.Decoder SendGroupFormResp
decodeSendGroupFormResp =
    decode SendGroupFormResp
        |> required "messages" (Decode.list decodeDjangoMessage)
        |> required "errors" decodeSendGroupFormError


decodeSendGroupFormError : Decode.Decoder SendGroupFormError
decodeSendGroupFormError =
    decode SendGroupFormError
        |> optional "group" (Decode.list Decode.string) []
        |> optional "scheduled_time" (Decode.list Decode.string) []
        |> optional "content" (Decode.list Decode.string) []
        |> optional "__all__" (Decode.list Decode.string) []


elvantogroupDecoder : Decode.Decoder ElvantoGroup
elvantogroupDecoder =
    decode ElvantoGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "sync" Decode.bool
        |> required "last_synced" (Decode.maybe date)


keywordDecoder : Decode.Decoder Keyword
keywordDecoder =
    decode Keyword
        |> required "keyword" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> required "current_response" Decode.string
        |> required "is_live" Decode.bool
        |> required "url" Decode.string
        |> required "responses_url" Decode.string
        |> required "num_replies" Decode.string
        |> required "num_archived_replies" Decode.string
        |> required "is_archived" Decode.bool


queuedsmsDecoder : Decode.Decoder QueuedSms
queuedsmsDecoder =
    decode QueuedSms
        |> required "pk" Decode.int
        |> required "time_to_send" (Decode.maybe date)
        |> required "time_to_send_formatted" Decode.string
        |> required "sent" Decode.bool
        |> required "failed" Decode.bool
        |> required "content" Decode.string
        |> required "recipient" recipientDecoder
        |> required "recipient_group" (Decode.maybe recipientgroupDecoder)
        |> required "sent_by" Decode.string


recipientgroupDecoder : Decode.Decoder RecipientGroup
recipientgroupDecoder =
    decode RecipientGroup
        |> required "name" Decode.string
        |> required "pk" Decode.int
        |> required "description" Decode.string
        |> optional "members" (Decode.list recipientsimpleDecoder) []
        |> optional "nonmembers" (Decode.list recipientsimpleDecoder) []
        |> required "cost" Decode.float
        |> required "url" Decode.string
        |> required "is_archived" Decode.bool


recipientDecoder : Decode.Decoder Recipient
recipientDecoder =
    decode Recipient
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "pk" Decode.int
        |> required "url" Decode.string
        |> required "full_name" Decode.string
        |> required "is_archived" Decode.bool
        |> required "is_blocking" Decode.bool
        |> required "do_not_reply" Decode.bool
        |> required "last_sms" (Decode.maybe smsinboundDecoder)


recipientsimpleDecoder : Decode.Decoder RecipientSimple
recipientsimpleDecoder =
    decode RecipientSimple
        |> required "full_name" Decode.string
        |> required "pk" Decode.int


smsinboundDecoder : Decode.Decoder SmsInbound
smsinboundDecoder =
    decode SmsInbound
        |> required "sid" Decode.string
        |> required "pk" Decode.int
        |> required "sender_name" Decode.string
        |> required "content" Decode.string
        |> required "time_received" (Decode.maybe date)
        |> required "dealt_with" Decode.bool
        |> required "is_archived" Decode.bool
        |> required "display_on_wall" Decode.bool
        |> required "matched_keyword" Decode.string
        |> required "matched_colour" Decode.string
        |> required "matched_link" Decode.string
        |> required "sender_url" (Decode.maybe Decode.string)
        |> required "sender_pk" (Decode.maybe Decode.int)


smsoutboundDecoder : Decode.Decoder SmsOutbound
smsoutboundDecoder =
    decode SmsOutbound
        |> required "content" Decode.string
        |> required "pk" Decode.int
        |> required "time_sent" (Decode.maybe date)
        |> required "sent_by" Decode.string
        |> required "recipient" (Decode.maybe recipientsimpleDecoder)


userprofileDecoder : Decode.Decoder UserProfile
userprofileDecoder =
    decode UserProfile
        |> required "pk" Decode.int
        |> required "user" userDecoder
        |> required "approved" Decode.bool
        |> required "can_see_groups" Decode.bool
        |> required "can_see_contact_names" Decode.bool
        |> required "can_see_keywords" Decode.bool
        |> required "can_see_outgoing" Decode.bool
        |> required "can_see_incoming" Decode.bool
        |> required "can_send_sms" Decode.bool
        |> required "can_see_contact_nums" Decode.bool
        |> required "can_import" Decode.bool
        |> required "can_archive" Decode.bool


userDecoder : Decode.Decoder User
userDecoder =
    decode User
        |> required "email" Decode.string
        |> required "username" Decode.string
        |> required "is_staff" Decode.bool
        |> required "is_social" Decode.bool


dataStoreDecoder : Decode.Decoder DataStore
dataStoreDecoder =
    decode DataStore
        |> required "inboundSms" (Decode.list smsinboundDecoder)
        |> required "outboundSms" (Decode.list smsoutboundDecoder)
        |> required "elvantoGroups" (Decode.list elvantogroupDecoder)
        |> required "userprofiles" (Decode.list userprofileDecoder)
        |> required "keywords" (Decode.list keywordDecoder)
        |> required "recipients" (Decode.list recipientDecoder)
        |> required "groups" (Decode.list recipientgroupDecoder)
        |> required "queuedSms" (Decode.list queuedsmsDecoder)
