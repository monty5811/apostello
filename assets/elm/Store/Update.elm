module Store.Update exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup, decodeElvantoGroup)
import Data.Keyword exposing (Keyword, decodeKeyword)
import Data.QueuedSms exposing (QueuedSms, decodeQueuedSms)
import Data.Recipient exposing (Recipient, RecipientSimple, decodeRecipient)
import Data.RecipientGroup exposing (RecipientGroup, decodeRecipientGroup)
import Data.SmsInbound exposing (SmsInbound, decodeSmsInbound)
import Data.SmsOutbound exposing (SmsOutbound, decodeSmsOutbound)
import Data.User exposing (User, UserProfile, decodeUser, decodeUserProfile)
import Date
import Dict
import Http
import Json.Decode as Decode
import Messages exposing (Msg)
import Models exposing (Model)
import Pages.FirstRun.Model exposing (decodeFirstRunResp)
import Pages.Fragments.Notification.Update as Notif
import Store.DataTypes exposing (RemoteDataType(..))
import Store.Decode exposing (decodeDataStore)
import Store.Messages exposing (StoreMsg(..))
import Store.Model exposing (..)
import Store.Optimistic as O
import Store.RemoteList as RL
import Store.Request exposing (dataFromResp, fetchData, increasePageSize, maybeFetchData)
import Store.Toggle as T


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
            let
                updatedGroup =
                    { group
                        | members = O.updateGroupMembers group.members contact
                        , nonmembers = O.updateGroupMembers group.nonmembers contact
                    }
            in
            ( { model | dataStore = updateGroups model.dataStore [ updatedGroup ] <| Just "dummy" }
            , [ T.groupMembership
                    model.settings.csrftoken
                    group.pk
                    contact.pk
                    (O.memberInList group.members contact)
              ]
            )

        ReceiveToggleGroupMembership (Ok group) ->
            ( { model | dataStore = updateGroups model.dataStore [ group ] <| Just "dummy" }, [] )

        ReceiveToggleGroupMembership (Err _) ->
            handleNotSaved model

        --  toggle elvanto group sync
        ToggleElvantoGroupSync group ->
            ( { model | dataStore = O.toggleElvantoGroup group model.dataStore }
            , [ T.elvantoGroupSync model.settings.csrftoken group ]
            )

        ReceiveToggleElvantoGroupSync (Ok group) ->
            ( { model | dataStore = updateElvantoGroups model.dataStore [ group ] <| Just "dummy" }, [] )

        ReceiveToggleElvantoGroupSync (Err _) ->
            handleNotSaved model

        -- scheduled sms
        CancelSms pk ->
            ( { model | dataStore = O.cancelSms model.dataStore pk }, [ T.cancelSms model.settings.csrftoken pk ] )

        -- archive recipient
        ToggleRecipientArchive isArchived pk ->
            ( { model | dataStore = O.removeRecipient model.dataStore pk }
            , [ T.recipientArchive model.settings.csrftoken isArchived pk ]
            )

        -- archive keyword
        ToggleKeywordArchive isArchived k ->
            ( { model
                | dataStore = O.archiveKeyword model.dataStore k
              }
            , [ T.archiveKeyword model.settings.csrftoken isArchived k ]
            )

        -- archive group
        ToggleGroupArchive isArchived pk ->
            ( { model | dataStore = O.archiveGroup model.dataStore pk }
            , [ T.recipientGroupArchive model.settings.csrftoken isArchived pk ]
            )

        -- inbound
        ReprocessSms pk ->
            ( model, [ T.reprocessSms model.settings.csrftoken pk ] )

        ReceiveReprocessSms (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveReprocessSms (Err _) ->
            handleNotSaved model

        ToggleInboundSmsArchive isArchived pk ->
            ( { model | dataStore = O.archiveSms model.dataStore pk }
            , [ T.smsArchive model.settings.csrftoken isArchived pk ]
            )

        ReceiveToggleInboundSmsArchive (Ok _) ->
            ( model, [] )

        ReceiveToggleInboundSmsArchive (Err _) ->
            handleNotSaved model

        ToggleInboundSmsDealtWith isDealtWith pk ->
            ( { model | dataStore = O.toggleDealtWith model.dataStore pk }
            , [ T.smsDealtWith model.settings.csrftoken isDealtWith pk ]
            )

        ReceiveToggleInboundSmsDealtWith (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveToggleInboundSmsDealtWith (Err _) ->
            handleNotSaved model

        -- wall
        ToggleWallDisplay isDisplayed pk ->
            ( model, [ T.wallDisplay model.settings.csrftoken isDisplayed pk ] )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveToggleWallDisplay (Err _) ->
            handleNotSaved model

        -- user profile
        ToggleProfileField profile ->
            ( { model
                | dataStore = updateUserProfiles model.dataStore [ profile ] <| Just "dummy"
              }
            , [ T.profileField model.settings.csrftoken profile ]
            )

        ReceiveToggleProfileField (Ok profile) ->
            ( { model
                | dataStore = updateUserProfiles model.dataStore [ profile ] <| Just "dummy"
              }
            , []
            )

        ReceiveToggleProfileField (Err _) ->
            handleNotSaved model

        -- lazy, do nothing on ok, show message on failed
        ReceiveLazy (Ok _) ->
            ( model, [] )

        ReceiveLazy (Err _) ->
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


updateStatus : Maybe String -> RL.RemoteList a -> RL.RemoteList a
updateStatus next rl =
    case next of
        Nothing ->
            RL.FinalPageReceived <| RL.toList rl

        _ ->
            RL.waitingHelper <| rl



-- Helpers


updateSmsOutbounds : DataStore -> List SmsOutbound -> Maybe String -> DataStore
updateSmsOutbounds ds sms next =
    { ds
        | outboundSms =
            RL.updateList (List.sortBy compareByTS >> List.reverse) mergeItems sms ds.outboundSms
                |> updateStatus next
    }


updateSmsInbounds : DataStore -> List SmsInbound -> Maybe String -> DataStore
updateSmsInbounds ds newSms next =
    { ds
        | inboundSms =
            RL.updateList sortByTimeReceived mergeItems newSms ds.inboundSms
                |> updateStatus next
    }


updateQueuedSms : DataStore -> List QueuedSms -> Maybe String -> DataStore
updateQueuedSms ds newSms next =
    { ds
        | queuedSms =
            RL.updateList (List.sortBy compareByT2S) mergeItems newSms ds.queuedSms
                |> updateStatus next
    }


updateKeywords : DataStore -> List Keyword -> Maybe String -> DataStore
updateKeywords ds keywords next =
    { ds
        | keywords =
            RL.updateList (List.sortBy .keyword) mergeItems keywords ds.keywords
                |> updateStatus next
    }


updateRecipients : DataStore -> List Recipient -> Maybe String -> DataStore
updateRecipients dataStore newRecipients next =
    { dataStore
        | recipients =
            RL.updateList (List.sortBy .last_name) mergeItems newRecipients dataStore.recipients
                |> updateStatus next
    }


updateGroups : DataStore -> List RecipientGroup -> Maybe String -> DataStore
updateGroups ds groups next =
    { ds
        | groups =
            RL.updateList (List.sortBy .name) mergeItems groups ds.groups
                |> updateStatus next
    }


updateUserProfiles : DataStore -> List UserProfile -> Maybe String -> DataStore
updateUserProfiles dataStore profiles next =
    { dataStore
        | userprofiles =
            RL.updateList (List.sortBy (.email << .user)) mergeItems profiles dataStore.userprofiles
                |> updateStatus next
    }


updateElvantoGroups : DataStore -> List ElvantoGroup -> Maybe String -> DataStore
updateElvantoGroups ds newGroups next =
    { ds
        | elvantoGroups =
            RL.updateList (List.sortBy .name) mergeItems newGroups ds.elvantoGroups
                |> updateStatus next
    }


updateUsers : DataStore -> List User -> Maybe String -> DataStore
updateUsers ds newUsers next =
    { ds
        | users =
            RL.updateList (List.sortBy .email) mergeItems newUsers ds.users
                |> updateStatus next
    }



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
