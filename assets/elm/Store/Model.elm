module Store.Model exposing (..)

import Data exposing (ElvantoGroup, Keyword, QueuedSms, Recipient, RecipientGroup, RecipientSimple, SmsInbound, SmsOutbound, User, UserProfile)
import Pages exposing (Page)
import RemoteList as RL
import Store.DataTypes exposing (..)


-- Data Store - shared data we pull from the server and re-use in different views/pages


type alias DataStore =
    { inboundSms : RL.RemoteList SmsInbound
    , outboundSms : RL.RemoteList SmsOutbound
    , elvantoGroups : RL.RemoteList ElvantoGroup
    , userprofiles : RL.RemoteList UserProfile
    , keywords : RL.RemoteList Keyword
    , recipients : RL.RemoteList Recipient
    , groups : RL.RemoteList RecipientGroup
    , queuedSms : RL.RemoteList QueuedSms
    , users : RL.RemoteList User
    }


type alias RawResponse =
    { body : String
    , next : Maybe String
    }


emptyDataStore : DataStore
emptyDataStore =
    { inboundSms = RL.NotAsked []
    , outboundSms = RL.NotAsked []
    , elvantoGroups = RL.NotAsked []
    , userprofiles = RL.NotAsked []
    , keywords = RL.NotAsked []
    , recipients = RL.NotAsked []
    , groups = RL.NotAsked []
    , queuedSms = RL.NotAsked []
    , users = RL.NotAsked []
    }


filterArchived : Bool -> RL.RemoteList { a | is_archived : Bool } -> RL.RemoteList { a | is_archived : Bool }
filterArchived viewingArchive data =
    data
        |> RL.filter (\x -> x.is_archived == viewingArchive)


setLoadDataStatus : RemoteDataType -> DataStore -> DataStore
setLoadDataStatus dt ds =
    case dt of
        IncomingSms ->
            { ds | inboundSms = setLoadDataStatusHelp ds.inboundSms }

        OutgoingSms ->
            { ds | outboundSms = setLoadDataStatusHelp ds.outboundSms }

        Contacts _ ->
            { ds | recipients = setLoadDataStatusHelp ds.recipients }

        Groups _ ->
            { ds | groups = setLoadDataStatusHelp ds.groups }

        Keywords _ ->
            { ds | keywords = setLoadDataStatusHelp ds.keywords }

        ScheduledSms ->
            { ds | queuedSms = setLoadDataStatusHelp ds.queuedSms }

        ElvantoGroups ->
            { ds | elvantoGroups = setLoadDataStatusHelp ds.elvantoGroups }

        UserProfiles ->
            { ds | userprofiles = setLoadDataStatusHelp ds.userprofiles }

        Users ->
            { ds | users = setLoadDataStatusHelp ds.users }


setLoadDataStatusHelp : RL.RemoteList a -> RL.RemoteList a
setLoadDataStatusHelp rl =
    case rl of
        RL.WaitingOnRefresh d ->
            RL.WaitingOnRefresh d

        RL.NotAsked d ->
            RL.WaitingForFirstResp d

        _ ->
            RL.WaitingForPage <| RL.toList rl


resetStatus : DataStore -> DataStore
resetStatus ds =
    { ds
        | inboundSms = RL.NotAsked <| RL.toList <| ds.inboundSms
        , outboundSms = RL.NotAsked <| RL.toList <| ds.outboundSms
        , recipients = RL.NotAsked <| RL.toList <| ds.recipients
        , groups = RL.NotAsked <| RL.toList <| ds.groups
        , keywords = RL.NotAsked <| RL.toList <| ds.keywords
        , queuedSms = RL.NotAsked <| RL.toList <| ds.queuedSms
        , elvantoGroups = RL.NotAsked <| RL.toList <| ds.elvantoGroups
        , userprofiles = RL.NotAsked <| RL.toList <| ds.userprofiles
        , users = RL.NotAsked <| RL.toList <| ds.users
    }


allFinished : Page -> DataStore -> Bool
allFinished page ds =
    dt_from_page page
        |> List.all (dt2Finished ds)


dt2Finished : DataStore -> RemoteDataType -> Bool
dt2Finished ds dt =
    case dt of
        IncomingSms ->
            ds.inboundSms |> RL.hasFinished

        OutgoingSms ->
            ds.outboundSms |> RL.hasFinished

        Contacts _ ->
            ds.recipients |> RL.hasFinished

        Groups _ ->
            ds.groups |> RL.hasFinished

        Keywords _ ->
            ds.keywords |> RL.hasFinished

        ScheduledSms ->
            ds.queuedSms |> RL.hasFinished

        ElvantoGroups ->
            ds.elvantoGroups |> RL.hasFinished

        UserProfiles ->
            ds.userprofiles |> RL.hasFinished

        Users ->
            ds.users |> RL.hasFinished


anyFailed : Page -> DataStore -> Bool
anyFailed page ds =
    dt_from_page page
        |> List.any (dt2Failed ds)


dt2Failed : DataStore -> RemoteDataType -> Bool
dt2Failed ds dt =
    case dt of
        IncomingSms ->
            ds.inboundSms |> RL.hasFailed

        OutgoingSms ->
            ds.outboundSms |> RL.hasFailed

        Contacts _ ->
            ds.recipients |> RL.hasFailed

        Groups _ ->
            ds.groups |> RL.hasFailed

        Keywords _ ->
            ds.keywords |> RL.hasFailed

        ScheduledSms ->
            ds.queuedSms |> RL.hasFailed

        ElvantoGroups ->
            ds.elvantoGroups |> RL.hasFailed

        UserProfiles ->
            ds.userprofiles |> RL.hasFailed

        Users ->
            ds.users |> RL.hasFailed


handleFailed : RemoteDataType -> String -> DataStore -> DataStore
handleFailed dt err ds =
    case dt of
        IncomingSms ->
            { ds | inboundSms = RL.RespFailed err <| RL.toList ds.inboundSms }

        OutgoingSms ->
            { ds | outboundSms = RL.RespFailed err <| RL.toList ds.outboundSms }

        Contacts _ ->
            { ds | recipients = RL.RespFailed err <| RL.toList ds.recipients }

        Groups _ ->
            { ds | groups = RL.RespFailed err <| RL.toList ds.groups }

        Keywords _ ->
            { ds | keywords = RL.RespFailed err <| RL.toList ds.keywords }

        ScheduledSms ->
            { ds | queuedSms = RL.RespFailed err <| RL.toList ds.queuedSms }

        ElvantoGroups ->
            { ds | elvantoGroups = RL.RespFailed err <| RL.toList ds.elvantoGroups }

        UserProfiles ->
            { ds | userprofiles = RL.RespFailed err <| RL.toList ds.userprofiles }

        Users ->
            { ds | users = RL.RespFailed err <| RL.toList ds.users }
