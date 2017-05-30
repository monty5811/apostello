module Data.Store.Update exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup)
import Data.Keyword exposing (Keyword, decodeKeyword)
import Data.QueuedSms exposing (QueuedSms, decodeQueuedSms)
import Data.Recipient exposing (Recipient, RecipientSimple, decodeRecipient)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup)
import Data.Request exposing (RawResponse, RemoteDataType(..), StoreMsg(..), dataFromResp, dt2Url, dt_from_page, increasePageSize, makeRequest)
import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.SmsOutbound exposing (SmsOutbound, decodeSmsOutbound)
import Data.Store exposing (..)
import Data.User exposing (User, UserProfile, decodeUser, decodeUserProfile)
import Date
import Dict
import DjangoSend exposing (post)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(StoreMsg))
import Models exposing (CSRFToken, Model)
import Pages.FirstRun.Model exposing (decodeFirstRunResp)
import Pages.Fragments.Notification.Update as Notif
import Urls


update : StoreMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        -- apostello list data
        LoadData ->
            ( model, [] ) |> maybeFetchData

        LoadDataStore str ->
            let
                ds =
                    Decode.decodeString (Decode.at [ "data" ] decodeDataStore) str
                        |> Result.withDefault model.dataStore
            in
            ( { model | dataStore = ds }, [] )

        ReceiveRawResp dt (Ok resp) ->
            let
                cmds =
                    case resp.next of
                        Nothing ->
                            []

                        Just url ->
                            [ fetchData ( dt, increasePageSize url ) ]
            in
            ( updateNewData dt resp model, cmds )

        ReceiveRawResp dt (Err e) ->
            handleLoadingFailed dt e model

        -- toggle group membership
        ToggleGroupMembership group contact ->
            ( { model | dataStore = optToggleGroupMember group model.dataStore contact }
            , [ toggleGroupMembership
                    model.settings.csrftoken
                    group.pk
                    contact.pk
                    (memberInList group.members contact)
              ]
            )

        ReceiveToggleGroupMembership (Ok group) ->
            ( { model | dataStore = updateGroups model.dataStore [ group ] <| Just "dummy" }, [] )

        ReceiveToggleGroupMembership (Err _) ->
            handleNotSaved model

        --  toggle elvanto group sync
        ToggleElvantoGroupSync group ->
            ( { model | dataStore = optToggleElvantoGroup group model.dataStore }
            , [ toggleElvantoGroupSync model.settings.csrftoken group ]
            )

        ReceiveToggleElvantoGroupSync (Ok group) ->
            ( { model | dataStore = updateElvantoGroups model.dataStore [ group ] <| Just "dummy" }, [] )

        ReceiveToggleElvantoGroupSync (Err _) ->
            handleNotSaved model


handleLoadingFailed : RemoteDataType -> Http.Error -> Model -> ( Model, List (Cmd Msg) )
handleLoadingFailed dt err model =
    let
        niceMsg =
            userFacingErrorMessage err

        ( newModel, cmd ) =
            { model | dataStore = handleFailed dt niceMsg model.dataStore }
                |> Notif.createLoadingFailed niceMsg
    in
    ( newModel, [ cmd ] )


optToggleGroupMember : RecipientGroup -> DataStore -> RecipientSimple -> DataStore
optToggleGroupMember group ds contact =
    let
        updatedGroup =
            { group
                | members = optUpdateGroupMemebers group.members contact
                , nonmembers = optUpdateGroupMemebers group.nonmembers contact
            }
    in
    updateGroups ds [ updatedGroup ] <| Just "dummy"


optUpdateGroupMemebers : List RecipientSimple -> RecipientSimple -> List RecipientSimple
optUpdateGroupMemebers existingList contact =
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


toggleGroupMembership : CSRFToken -> Int -> Int -> Bool -> Cmd Msg
toggleGroupMembership csrftoken groupPk contactPk isMember =
    let
        body =
            [ ( "member", Encode.bool isMember )
            , ( "contactPk", Encode.int contactPk )
            ]

        url =
            Urls.api_act_update_group_members groupPk
    in
    post csrftoken url body decodeRecipientGroup
        |> Http.send (StoreMsg << ReceiveToggleGroupMembership)


maybeFetchData : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
maybeFetchData ( model, cmds ) =
    let
        dataTypes =
            dt_from_page model.page

        newDs =
            dataTypes
                |> List.foldl setLoadDataStatus model.dataStore

        fetchCmds =
            dataTypes
                |> List.map (\dt -> ( dt, dt2Url dt ))
                |> List.map fetchData
    in
    ( { model | dataStore = newDs }, List.concat [ fetchCmds, cmds ] )


fetchData : ( RemoteDataType, String ) -> Cmd Msg
fetchData ( dt, url ) =
    makeRequest url
        |> Http.send (StoreMsg << ReceiveRawResp dt)


toggleElvantoGroupSync : CSRFToken -> ElvantoGroup -> Cmd Msg
toggleElvantoGroupSync csrftoken group =
    let
        url =
            Urls.api_toggle_elvanto_group_sync group.pk

        body =
            [ ( "sync", Encode.bool group.sync ) ]
    in
    post csrftoken url body decodeElvantoGroup
        |> Http.send (Messages.StoreMsg << ReceiveToggleElvantoGroupSync)


optToggleElvantoGroup : ElvantoGroup -> DataStore -> DataStore
optToggleElvantoGroup group ds =
    { ds | elvantoGroups = map (toggleGroupSync group.pk) ds.elvantoGroups }


toggleGroupSync : Int -> ElvantoGroup -> ElvantoGroup
toggleGroupSync pk group =
    if pk == group.pk then
        { group | sync = not group.sync }
    else
        group


handleNotSaved : Model -> ( Model, List (Cmd Msg) )
handleNotSaved model =
    let
        ( newModel, cmd ) =
            Notif.createNotSaved model
    in
    ( newModel, [ cmd ] )


updateNewData : RemoteDataType -> RawResponse -> Model -> Model
updateNewData dt rawResp model =
    case dt of
        OutgoingSms ->
            { model | dataStore = updateSmsOutbounds model.dataStore (dataFromResp decodeSmsOutbound rawResp) rawResp.next }

        IncomingSms ->
            { model | dataStore = updateSmsInbounds model.dataStore (dataFromResp decodeSmsInbound rawResp) rawResp.next }

        Groups ->
            { model | dataStore = updateGroups model.dataStore (dataFromResp decodeRecipientGroup rawResp) rawResp.next }

        Contacts ->
            { model | dataStore = updateRecipients model.dataStore (dataFromResp decodeRecipient rawResp) rawResp.next }

        Keywords ->
            { model | dataStore = updateKeywords model.dataStore (dataFromResp decodeKeyword rawResp) rawResp.next }

        ElvantoGroups ->
            { model | dataStore = updateElvantoGroups model.dataStore (dataFromResp decodeElvantoGroup rawResp) rawResp.next }

        UserProfiles ->
            { model | dataStore = updateUserProfiles model.dataStore (dataFromResp decodeUserProfile rawResp) rawResp.next }

        ScheduledSms ->
            { model | dataStore = updateQueuedSms model.dataStore (dataFromResp decodeQueuedSms rawResp) rawResp.next }

        Users ->
            { model | dataStore = updateUsers model.dataStore (dataFromResp decodeUser rawResp) rawResp.next }


updateStatus : Maybe String -> RemoteList a -> RemoteList a
updateStatus next rl =
    case next of
        Nothing ->
            FinalPageReceived <| toList rl

        _ ->
            waitingHelper <| rl



-- Helpers


updateSmsOutbounds : DataStore -> List SmsOutbound -> Maybe String -> DataStore
updateSmsOutbounds ds sms next =
    { ds
        | outboundSms =
            updateList (List.sortBy compareByTS >> List.reverse) mergeItems sms ds.outboundSms
                |> updateStatus next
    }


updateSmsInbounds : DataStore -> List SmsInbound -> Maybe String -> DataStore
updateSmsInbounds ds newSms next =
    { ds
        | inboundSms =
            updateList sortByTimeReceived mergeItems newSms ds.inboundSms
                |> updateStatus next
    }


updateQueuedSms : DataStore -> List QueuedSms -> Maybe String -> DataStore
updateQueuedSms ds newSms next =
    { ds
        | queuedSms =
            updateList (List.sortBy compareByT2S) mergeItems newSms ds.queuedSms
                |> updateStatus next
    }


updateKeywords : DataStore -> List Keyword -> Maybe String -> DataStore
updateKeywords ds keywords next =
    { ds
        | keywords =
            updateList (List.sortBy .keyword) mergeItems keywords ds.keywords
                |> updateStatus next
    }


updateRecipients : DataStore -> List Recipient -> Maybe String -> DataStore
updateRecipients dataStore newRecipients next =
    { dataStore
        | recipients =
            updateList (List.sortBy .last_name) mergeItems newRecipients dataStore.recipients
                |> updateStatus next
    }


updateGroups : DataStore -> List RecipientGroup -> Maybe String -> DataStore
updateGroups ds groups next =
    { ds
        | groups =
            updateList (List.sortBy .name) mergeItems groups ds.groups
                |> updateStatus next
    }


updateUserProfiles : DataStore -> List UserProfile -> Maybe String -> DataStore
updateUserProfiles dataStore profiles next =
    { dataStore
        | userprofiles =
            updateList (List.sortBy (.email << .user)) mergeItems profiles dataStore.userprofiles
                |> updateStatus next
    }


updateElvantoGroups : DataStore -> List ElvantoGroup -> Maybe String -> DataStore
updateElvantoGroups ds newGroups next =
    { ds
        | elvantoGroups =
            updateList (List.sortBy .name) mergeItems newGroups ds.elvantoGroups
                |> updateStatus next
    }


updateUsers : DataStore -> List User -> Maybe String -> DataStore
updateUsers ds newUsers next =
    { ds
        | users =
            updateList (List.sortBy .email) mergeItems newUsers ds.users
                |> updateStatus next
    }


optArchiveRecordWithPk : Int -> { a | pk : Int, is_archived : Bool } -> { a | pk : Int, is_archived : Bool }
optArchiveRecordWithPk pk rec =
    toggleIsArchived pk rec


toggleIsArchived : Int -> { a | pk : Int, is_archived : Bool } -> { a | pk : Int, is_archived : Bool }
toggleIsArchived pk rec =
    case pk == rec.pk of
        True ->
            { rec | is_archived = not rec.is_archived }

        False ->
            rec



-- merge new items with existing


mergeItems : List { a | pk : Int } -> List { a | pk : Int } -> List { a | pk : Int }
mergeItems existingItems newItems =
    existingItems
        |> List.map (\x -> ( x.pk, x ))
        |> Dict.fromList
        |> addNewItems newItems
        |> Dict.values


addNewItems : List { a | pk : Int } -> Dict.Dict Int { a | pk : Int } -> Dict.Dict Int { a | pk : Int }
addNewItems newItems existingItemsDict =
    newItems
        |> List.foldl addItemToDic existingItemsDict


addItemToDic : { a | pk : Int } -> Dict.Dict Int { a | pk : Int } -> Dict.Dict Int { a | pk : Int }
addItemToDic item existingItems =
    Dict.insert item.pk item existingItems



-- Sorting


compareByTS : SmsOutbound -> Float
compareByTS sms =
    case sms.time_sent of
        Just d ->
            Date.toTime d

        Nothing ->
            toFloat 1


compareByT2S : { a | time_to_send : Maybe Date.Date } -> Float
compareByT2S sms =
    case sms.time_to_send of
        Just d ->
            Date.toTime d

        Nothing ->
            toFloat 1


sortByTimeReceived : List { a | time_received : Maybe Date.Date } -> List { a | time_received : Maybe Date.Date }
sortByTimeReceived items =
    items
        |> List.sortBy compareTR
        |> List.reverse


compareTR : { a | time_received : Maybe Date.Date } -> Float
compareTR item =
    case item.time_received of
        Just d ->
            Date.toTime d

        Nothing ->
            toFloat 1


userFacingErrorMessage : Http.Error -> String
userFacingErrorMessage err =
    case err of
        Http.BadUrl _ ->
            "That's a bad URL. Sorry."

        Http.NetworkError ->
            "Looks like there may be something wrong with your internet connection :("

        Http.BadStatus r ->
            r.body
                |> Decode.decodeString decodeFirstRunResp
                |> Result.withDefault { status = "", error = "Something went wrong there. Sorry. (" ++ r.body ++ ")" }
                |> .error

        Http.BadPayload msg _ ->
            "Something went wrong there. Sorry. (" ++ msg ++ ")"

        Http.Timeout ->
            "It took too long to reach the server..."
