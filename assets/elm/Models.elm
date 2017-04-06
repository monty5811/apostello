module Models
    exposing
        ( Model
        , DataStore
        , Settings
        , Notification
        , NotificationType(..)
        , CSRFToken
        , LoadingStatus(..)
        , FabModel(..)
        , Flags
        , initialModel
        , decodeDataStore
        , encodeDataStore
        )

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required, decode)
import Json.Encode as Encode
import Models.Apostello exposing (..)
import Models.DjangoMessage exposing (DjangoMessage)
import Models.FirstRun exposing (..)
import Models.GroupComposer exposing (..)
import Models.GroupMemberSelect exposing (..)
import Models.SendAdhocForm exposing (..)
import Models.SendGroupForm exposing (..)
import Pages exposing (Page)
import Regex
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
    , notifications : Dict Int Notification
    , currentTime : Time.Time
    }


initialModel : Settings -> String -> Page -> Model
initialModel settings dataStoreCache page =
    { page = page
    , loadingStatus = NoRequestSent
    , filterRegex = Regex.regex ""
    , settings = settings
    , dataStore = Result.withDefault emptyDataStore <| Decode.decodeString decodeDataStore dataStoreCache
    , groupComposer = initialGroupComposerModel
    , groupSelect = initialGroupMemberSelectModel
    , keyRespTable = False
    , firstRun = initialFirstRunModel
    , sendAdhoc = initialSendAdhocModel page
    , sendGroup = initialSendGroupModel page
    , fabModel = initialFabModel
    , notifications = Dict.empty
    , currentTime = 0
    }



-- Settings


type alias Settings =
    { csrftoken : CSRFToken
    , userPerms : UserProfile
    , twilioSendingCost : Float
    , twilioFromNumber : String
    , smsCharLimit : Int
    , blockedKeywords : List String
    }



-- Data Store - shared data we pull from the server and re-use in different views/pages


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


type alias DataStoreStatus =
    { inboundSms : LoadingStatus
    , outboundSms : LoadingStatus
    , elvantoGroups : LoadingStatus
    , userprofiles : LoadingStatus
    , keywords : LoadingStatus
    , recipients : LoadingStatus
    , groups : LoadingStatus
    , queuedSms : LoadingStatus
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


decodeDataStore : Decode.Decoder DataStore
decodeDataStore =
    decode DataStore
        |> required "inboundSms" (Decode.list decodeSmsInbound)
        |> required "outboundSms" (Decode.list decodeSmsOutbound)
        |> required "elvantoGroups" (Decode.list decodeElvantoGroup)
        |> required "userprofiles" (Decode.list decodeUserProfile)
        |> required "keywords" (Decode.list decodeKeyword)
        |> required "recipients" (Decode.list decodeRecipient)
        |> required "groups" (Decode.list decodeRecipientGroup)
        |> required "queuedSms" (Decode.list decodeQueuedSms)


encodeDataStore : DataStore -> Encode.Value
encodeDataStore ds =
    Encode.object
        [ ( "inboundSms", Encode.list <| List.map encodeSmsInbound ds.inboundSms )
        , ( "outboundSms", Encode.list <| List.map encodeSmsOutbound ds.outboundSms )
        , ( "elvantoGroups", Encode.list <| List.map encodeElvantoGroup ds.elvantoGroups )
        , ( "userprofiles", Encode.list <| List.map encodeUserProfile ds.userprofiles )
        , ( "keywords", Encode.list <| List.map encodeKeyword ds.keywords )
        , ( "recipients", Encode.list <| List.map encodeRecipient ds.recipients )
        , ( "groups", Encode.list <| List.map encodeRecipientGroup ds.groups )
        , ( "queuedSms", Encode.list <| List.map encodeQueuedSms ds.queuedSms )
        ]



--


type alias Flags =
    { settings : Settings
    , messages : List DjangoMessage
    , dataStoreCache : Maybe String
    }


type alias Notification =
    { type_ : NotificationType
    , text : String
    }


type NotificationType
    = InfoNotification
    | SuccessNotification
    | WarningNotification
    | ErrorNotification


type LoadingStatus
    = NoRequestSent
    | WaitingForFirstResp
    | WaitingForPage
    | FinalPageReceived
    | WaitingOnRefresh
    | RespFailed String



-- CSRF Token - required for post requests


type alias CSRFToken =
    String



-- FAB model


type FabModel
    = MenuHidden
    | MenuVisible


initialFabModel : FabModel
initialFabModel =
    MenuHidden
