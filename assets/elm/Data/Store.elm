module Data.Store exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup, encodeElvantoGroup)
import Data.Keyword exposing (Keyword, decodeKeyword, encodeKeyword)
import Data.QueuedSms exposing (QueuedSms, decodeQueuedSms, encodeQueuedSms)
import Data.Recipient exposing (Recipient, RecipientSimple, decodeRecipient, encodeRecipient)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup, encodeRecipientGroup)
import Data.Request exposing (RemoteDataType(..), dt_from_page)
import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound, encodeSmsInbound)
import Data.SmsOutbound exposing (SmsOutbound, decodeSmsOutbound, encodeSmsOutbound)
import Data.User exposing (User, UserProfile, decodeUser, decodeUserProfile, encodeUser, encodeUserProfile)
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Pages exposing (Page)


-- Data Store - shared data we pull from the server and re-use in different views/pages


type alias DataStore =
    { inboundSms : RemoteList SmsInbound
    , outboundSms : RemoteList SmsOutbound
    , elvantoGroups : RemoteList ElvantoGroup
    , userprofiles : RemoteList UserProfile
    , keywords : RemoteList Keyword
    , recipients : RemoteList Recipient
    , groups : RemoteList RecipientGroup
    , queuedSms : RemoteList QueuedSms
    , users : RemoteList User
    }


type RemoteList a
    = NotAsked (List a)
    | WaitingForFirstResp (List a)
    | WaitingForPage (List a)
    | FinalPageReceived (List a)
    | WaitingOnRefresh (List a)
    | RespFailed String (List a)


emptyDataStore : DataStore
emptyDataStore =
    { inboundSms = NotAsked []
    , outboundSms = NotAsked []
    , elvantoGroups = NotAsked []
    , userprofiles = NotAsked []
    , keywords = NotAsked []
    , recipients = NotAsked []
    , groups = NotAsked []
    , queuedSms = NotAsked []
    , users = NotAsked []
    }


waitingHelper : RemoteList a -> RemoteList a
waitingHelper rl =
    case rl of
        WaitingOnRefresh d ->
            WaitingOnRefresh d

        NotAsked d ->
            WaitingForFirstResp d

        _ ->
            WaitingForPage <| toList rl


setLoadDataStatus : RemoteDataType -> DataStore -> DataStore
setLoadDataStatus dt ds =
    case dt of
        IncomingSms ->
            { ds | inboundSms = waitingHelper ds.inboundSms }

        OutgoingSms ->
            { ds | outboundSms = waitingHelper ds.outboundSms }

        Contacts ->
            { ds | recipients = waitingHelper ds.recipients }

        Groups ->
            { ds | groups = waitingHelper ds.groups }

        Keywords ->
            { ds | keywords = waitingHelper ds.keywords }

        ScheduledSms ->
            { ds | queuedSms = waitingHelper ds.queuedSms }

        ElvantoGroups ->
            { ds | elvantoGroups = waitingHelper ds.elvantoGroups }

        UserProfiles ->
            { ds | userprofiles = waitingHelper ds.userprofiles }

        Users ->
            { ds | users = waitingHelper ds.users }


resetStatus : DataStore -> DataStore
resetStatus ds =
    { ds
        | inboundSms = NotAsked <| toList <| ds.inboundSms
        , outboundSms = NotAsked <| toList <| ds.outboundSms
        , recipients = NotAsked <| toList <| ds.recipients
        , groups = NotAsked <| toList <| ds.groups
        , keywords = NotAsked <| toList <| ds.keywords
        , queuedSms = NotAsked <| toList <| ds.queuedSms
        , elvantoGroups = NotAsked <| toList <| ds.elvantoGroups
        , userprofiles = NotAsked <| toList <| ds.userprofiles
        , users = NotAsked <| toList <| ds.users
    }


allFinishedHelper : RemoteList a -> Bool
allFinishedHelper ls =
    case ls of
        FinalPageReceived _ ->
            True

        _ ->
            False


anyFailedHelper : RemoteList a -> Bool
anyFailedHelper ls =
    case ls of
        RespFailed _ _ ->
            True

        _ ->
            False


dt2Finished : DataStore -> RemoteDataType -> Bool
dt2Finished ds dt =
    case dt of
        IncomingSms ->
            ds.inboundSms |> allFinishedHelper

        OutgoingSms ->
            ds.outboundSms |> allFinishedHelper

        Contacts ->
            ds.recipients |> allFinishedHelper

        Groups ->
            ds.groups |> allFinishedHelper

        Keywords ->
            ds.keywords |> allFinishedHelper

        ScheduledSms ->
            ds.queuedSms |> allFinishedHelper

        ElvantoGroups ->
            ds.elvantoGroups |> allFinishedHelper

        UserProfiles ->
            ds.userprofiles |> allFinishedHelper

        Users ->
            ds.users |> allFinishedHelper


allFinished : Page -> DataStore -> Bool
allFinished page ds =
    dt_from_page page
        |> List.all (dt2Finished ds)


dt2Failed : DataStore -> RemoteDataType -> Bool
dt2Failed ds dt =
    case dt of
        IncomingSms ->
            ds.inboundSms |> anyFailedHelper

        OutgoingSms ->
            ds.outboundSms |> anyFailedHelper

        Contacts ->
            ds.recipients |> anyFailedHelper

        Groups ->
            ds.groups |> anyFailedHelper

        Keywords ->
            ds.keywords |> anyFailedHelper

        ScheduledSms ->
            ds.queuedSms |> anyFailedHelper

        ElvantoGroups ->
            ds.elvantoGroups |> anyFailedHelper

        UserProfiles ->
            ds.userprofiles |> anyFailedHelper

        Users ->
            ds.users |> anyFailedHelper


anyFailed : Page -> DataStore -> Bool
anyFailed page ds =
    dt_from_page page
        |> List.any (dt2Failed ds)


toList : RemoteList a -> List a
toList rl =
    case rl of
        NotAsked l ->
            l

        WaitingForFirstResp l ->
            l

        WaitingForPage l ->
            l

        FinalPageReceived l ->
            l

        WaitingOnRefresh l ->
            l

        RespFailed _ l ->
            l


handleFailed : RemoteDataType -> String -> DataStore -> DataStore
handleFailed dt err ds =
    case dt of
        IncomingSms ->
            { ds | inboundSms = RespFailed err <| toList ds.inboundSms }

        OutgoingSms ->
            { ds | outboundSms = RespFailed err <| toList ds.outboundSms }

        Contacts ->
            { ds | recipients = RespFailed err <| toList ds.recipients }

        Groups ->
            { ds | groups = RespFailed err <| toList ds.groups }

        Keywords ->
            { ds | keywords = RespFailed err <| toList ds.keywords }

        ScheduledSms ->
            { ds | queuedSms = RespFailed err <| toList ds.queuedSms }

        ElvantoGroups ->
            { ds | elvantoGroups = RespFailed err <| toList ds.elvantoGroups }

        UserProfiles ->
            { ds | userprofiles = RespFailed err <| toList ds.userprofiles }

        Users ->
            { ds | users = RespFailed err <| toList ds.users }


map : (a -> a) -> RemoteList a -> RemoteList a
map fn rl =
    case rl of
        NotAsked l ->
            NotAsked <| List.map fn l

        WaitingForFirstResp l ->
            WaitingForFirstResp <| List.map fn l

        WaitingForPage l ->
            WaitingForPage <| List.map fn l

        FinalPageReceived l ->
            FinalPageReceived <| List.map fn l

        WaitingOnRefresh l ->
            WaitingOnRefresh <| List.map fn l

        RespFailed err l ->
            RespFailed err <| List.map fn l


updateList : (List a -> List a) -> (List a -> List a -> List a) -> List a -> RemoteList a -> RemoteList a
updateList sortFn mergeFn newItems rl =
    case rl of
        NotAsked l ->
            NotAsked <| sortFn <| mergeFn l newItems

        WaitingForFirstResp l ->
            WaitingForFirstResp <| sortFn <| mergeFn l newItems

        WaitingForPage l ->
            WaitingForPage <| sortFn <| mergeFn l newItems

        FinalPageReceived l ->
            FinalPageReceived <| sortFn <| mergeFn l newItems

        WaitingOnRefresh l ->
            WaitingOnRefresh <| sortFn <| mergeFn l newItems

        RespFailed err l ->
            RespFailed err <| sortFn <| mergeFn l newItems


filterArchived : Bool -> RemoteList { a | is_archived : Bool } -> RemoteList { a | is_archived : Bool }
filterArchived viewingArchive data =
    data
        |> filter (\x -> x.is_archived == viewingArchive)


filter : (a -> Bool) -> RemoteList a -> RemoteList a
filter filt rl =
    case rl of
        NotAsked l ->
            NotAsked <| List.filter filt l

        WaitingForFirstResp l ->
            WaitingForFirstResp <| List.filter filt l

        WaitingForPage l ->
            WaitingForPage <| List.filter filt l

        FinalPageReceived l ->
            FinalPageReceived <| List.filter filt l

        WaitingOnRefresh l ->
            WaitingOnRefresh <| List.filter filt l

        RespFailed err l ->
            RespFailed err <| List.filter filt l


remoteList : List a -> Decode.Decoder (RemoteList a)
remoteList l =
    Decode.succeed (NotAsked l)


decodeDataStore : Decode.Decoder DataStore
decodeDataStore =
    decode DataStore
        |> required "inboundSms" (Decode.list decodeSmsInbound |> Decode.andThen remoteList)
        |> required "outboundSms" (Decode.list decodeSmsOutbound |> Decode.andThen remoteList)
        |> required "elvantoGroups" (Decode.list decodeElvantoGroup |> Decode.andThen remoteList)
        |> required "userprofiles" (Decode.list decodeUserProfile |> Decode.andThen remoteList)
        |> required "keywords" (Decode.list decodeKeyword |> Decode.andThen remoteList)
        |> required "recipients" (Decode.list decodeRecipient |> Decode.andThen remoteList)
        |> required "groups" (Decode.list decodeRecipientGroup |> Decode.andThen remoteList)
        |> required "queuedSms" (Decode.list decodeQueuedSms |> Decode.andThen remoteList)
        |> required "users" (Decode.list decodeUser |> Decode.andThen remoteList)


encodeDataStore : DataStore -> Encode.Value
encodeDataStore ds =
    Encode.object
        [ ( "inboundSms", Encode.list <| List.map encodeSmsInbound <| toList ds.inboundSms )
        , ( "outboundSms", Encode.list <| List.map encodeSmsOutbound <| toList ds.outboundSms )
        , ( "elvantoGroups", Encode.list <| List.map encodeElvantoGroup <| toList ds.elvantoGroups )
        , ( "userprofiles", Encode.list <| List.map encodeUserProfile <| toList ds.userprofiles )
        , ( "keywords", Encode.list <| List.map encodeKeyword <| toList ds.keywords )
        , ( "recipients", Encode.list <| List.map encodeRecipient <| toList ds.recipients )
        , ( "groups", Encode.list <| List.map encodeRecipientGroup <| toList ds.groups )
        , ( "queuedSms", Encode.list <| List.map encodeQueuedSms <| toList ds.queuedSms )
        , ( "users", Encode.list <| List.map encodeUser <| toList ds.users )
        ]
