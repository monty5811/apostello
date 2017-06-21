module Store.Optimistic exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup)
import Data.Recipient exposing (RecipientSimple)
import Data.SmsInbound exposing (SmsInbound)
import Store.Model exposing (DataStore)
import RemoteList as RL


archiveSms : DataStore -> Int -> DataStore
archiveSms ds pk =
    { ds | inboundSms = RL.map (archiveRecordWithPk pk) ds.inboundSms }


toggleDealtWith : DataStore -> Int -> DataStore
toggleDealtWith ds pk =
    { ds | inboundSms = RL.map (switchDealtWith pk) ds.inboundSms }


switchDealtWith : Int -> SmsInbound -> SmsInbound
switchDealtWith pk sms =
    if pk == sms.pk then
        { sms | dealt_with = not sms.dealt_with }
    else
        sms


archiveGroup : DataStore -> Int -> DataStore
archiveGroup ds pk =
    { ds | groups = RL.map (archiveRecordWithPk pk) ds.groups }


updateGroupMembers : List RecipientSimple -> RecipientSimple -> List RecipientSimple
updateGroupMembers existingList contact =
    case memberInList existingList contact of
        True ->
            existingList
                |> List.filter (\x -> not (x.pk == contact.pk))

        False ->
            contact :: existingList


memberInList : List RecipientSimple -> RecipientSimple -> Bool
memberInList existingList contact =
    List.map (\x -> x.pk) existingList
        |> List.member contact.pk


toggleElvantoGroup : ElvantoGroup -> DataStore -> DataStore
toggleElvantoGroup group ds =
    { ds | elvantoGroups = RL.map (toggleGroupSync group.pk) ds.elvantoGroups }


toggleGroupSync : Int -> ElvantoGroup -> ElvantoGroup
toggleGroupSync pk group =
    if pk == group.pk then
        { group | sync = not group.sync }
    else
        group


archiveKeyword : DataStore -> String -> DataStore
archiveKeyword ds k =
    { ds | keywords = RL.map (archiveKeywordHelper k) ds.keywords }


archiveKeywordHelper : String -> { a | keyword : String, is_archived : Bool } -> { a | keyword : String, is_archived : Bool }
archiveKeywordHelper k rec =
    case k == rec.keyword of
        True ->
            { rec | is_archived = not rec.is_archived }

        False ->
            rec


removeRecipient : DataStore -> Int -> DataStore
removeRecipient ds pk =
    { ds | recipients = RL.map (archiveRecordWithPk pk) ds.recipients }


cancelSms : DataStore -> Int -> DataStore
cancelSms ds pk =
    { ds | queuedSms = RL.filter (\r -> not (r.pk == pk)) ds.queuedSms }


archiveRecordWithPk : Int -> { a | pk : Int, is_archived : Bool } -> { a | pk : Int, is_archived : Bool }
archiveRecordWithPk pk rec =
    toggleIsArchivedPk pk rec


toggleIsArchivedPk : Int -> { a | pk : Int, is_archived : Bool } -> { a | pk : Int, is_archived : Bool }
toggleIsArchivedPk pk rec =
    case pk == rec.pk of
        True ->
            { rec | is_archived = not rec.is_archived }

        False ->
            rec
