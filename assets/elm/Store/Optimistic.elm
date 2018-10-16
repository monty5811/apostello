module Store.Optimistic exposing (archiveGroup, archiveKeyword, archiveKeywordHelper, archiveMatches, archiveRecordWithPk, archiveSms, cancelSms, memberInList, optArchiveMatchingSms, removeRecipient, switchDealtWith, toggleDealtWith, toggleElvantoGroup, toggleGroupSync, toggleIsArchivedPk, updateGroupMembers)

import RemoteList as RL
import Store.Model exposing (DataStore)


archiveSms : DataStore -> Int -> DataStore
archiveSms ds pk =
    { ds | inboundSms = RL.map (archiveRecordWithPk pk) ds.inboundSms }


toggleDealtWith : DataStore -> Int -> DataStore
toggleDealtWith ds pk =
    { ds | inboundSms = RL.map (switchDealtWith pk) ds.inboundSms }


switchDealtWith : Int -> { a | dealt_with : Bool, pk : Int } -> { a | dealt_with : Bool, pk : Int }
switchDealtWith pk sms =
    if pk == sms.pk then
        { sms | dealt_with = not sms.dealt_with }
    else
        sms


archiveGroup : DataStore -> Int -> DataStore
archiveGroup ds pk =
    { ds | groups = RL.map (archiveRecordWithPk pk) ds.groups }


updateGroupMembers : List { a | pk : Int } -> { a | pk : Int } -> List { a | pk : Int }
updateGroupMembers existingList contact =
    case memberInList existingList contact of
        True ->
            existingList
                |> List.filter (\x -> not (x.pk == contact.pk))

        False ->
            contact :: existingList


memberInList : List { a | pk : Int } -> { a | pk : Int } -> Bool
memberInList existingList contact =
    List.map .pk existingList
        |> List.member contact.pk


toggleElvantoGroup : { a | pk : Int } -> DataStore -> DataStore
toggleElvantoGroup group ds =
    { ds | elvantoGroups = RL.map (toggleGroupSync group.pk) ds.elvantoGroups }


toggleGroupSync : Int -> { a | sync : Bool, pk : Int } -> { a | sync : Bool, pk : Int }
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


optArchiveMatchingSms : String -> DataStore -> DataStore
optArchiveMatchingSms k ds =
    { ds | inboundSms = RL.map (archiveMatches k) ds.inboundSms }


archiveMatches : String -> { a | matched_keyword : String, is_archived : Bool } -> { a | matched_keyword : String, is_archived : Bool }
archiveMatches k sms =
    case sms.matched_keyword == k of
        True ->
            { sms | is_archived = True }

        False ->
            sms
