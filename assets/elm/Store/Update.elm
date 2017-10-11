module Store.Update exposing (..)

import Data exposing (ElvantoGroup, Keyword, QueuedSms, Recipient, RecipientGroup, RecipientSimple, SmsInbound, SmsOutbound, User, UserProfile, decodeElvantoGroup, decodeKeyword, decodeQueuedSms, decodeRecipient, decodeRecipientGroup, decodeSmsInbound, decodeSmsOutbound, decodeUser, decodeUserProfile)
import Date
import Dict
import Helpers exposing (handleNotSaved)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Models exposing (Model)
import Notification as Notif
import RemoteList as RL
import Rocket exposing ((=>))
import Store.DataTypes exposing (RemoteDataType(..))
import Store.Decode exposing (decodeDataStore)
import Store.Messages exposing (StoreMsg(..))
import Store.Model exposing (..)
import Store.Optimistic as O
import Store.Request exposing (dataFromResp, fetchData, increasePageSize, maybeFetchData)
import Store.Toggle as T


update : StoreMsg -> Model -> ( Model, List (Cmd StoreMsg) )
update msg model =
    case msg of
        -- apostello list data
        LoadData ->
            let
                ( ds, cmds ) =
                    maybeFetchData model.page model.dataStore
            in
            { model | dataStore = ds } => cmds

        LoadDataStore str ->
            let
                ds =
                    Decode.decodeString (Decode.at [ "data" ] decodeDataStore) str
                        |> Result.withDefault model.dataStore
            in
            ( { model | dataStore = ds }, [] )

        ReceiveRawResp dt ignorePageInfo (Ok resp) ->
            let
                cmds =
                    case ignorePageInfo of
                        True ->
                            []

                        False ->
                            case resp.next of
                                Nothing ->
                                    []

                                Just url ->
                                    [ fetchData ( dt, ( False, increasePageSize url ) ) ]
            in
            ( updateNewData ignorePageInfo dt resp model, cmds )

        ReceiveRawResp dt _ (Err e) ->
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
            ( { model | dataStore = updateGroups False model.dataStore [ updatedGroup ] <| Just "dummy" }
            , [ T.groupMembership
                    model.settings.csrftoken
                    group.pk
                    contact.pk
                    (O.memberInList group.members contact)
              ]
            )

        ReceiveToggleGroupMembership (Ok group) ->
            ( { model | dataStore = updateGroups False model.dataStore [ group ] <| Just "dummy" }, [] )

        ReceiveToggleGroupMembership (Err _) ->
            handleNotSaved model

        --  toggle elvanto group sync
        ToggleElvantoGroupSync group ->
            ( { model | dataStore = O.toggleElvantoGroup group model.dataStore }
            , [ T.elvantoGroupSync model.settings.csrftoken group ]
            )

        ReceiveToggleElvantoGroupSync (Ok group) ->
            ( { model | dataStore = updateElvantoGroups False model.dataStore [ group ] <| Just "dummy" }, [] )

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
            ( { model | dataStore = updateSmsInbounds False model.dataStore [ sms ] <| Just "dummy" }, [] )

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
            ( { model | dataStore = updateSmsInbounds False model.dataStore [ sms ] <| Just "dummy" }, [] )

        ReceiveToggleInboundSmsDealtWith (Err _) ->
            handleNotSaved model

        -- wall
        ToggleWallDisplay isDisplayed pk ->
            ( model, [ T.wallDisplay model.settings.csrftoken isDisplayed pk ] )

        ReceiveToggleWallDisplay (Ok sms) ->
            ( { model | dataStore = updateSmsInbounds True model.dataStore [ sms ] Nothing }, [] )

        ReceiveToggleWallDisplay (Err _) ->
            handleNotSaved model

        -- user profile
        ToggleProfileField profile ->
            ( { model
                | dataStore = updateUserProfiles False model.dataStore [ profile ] <| Just "dummy"
              }
            , [ T.profileField model.settings.csrftoken profile ]
            )

        ReceiveToggleProfileField (Ok profile) ->
            ( { model
                | dataStore = updateUserProfiles False model.dataStore [ profile ] <| Just "dummy"
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


handleLoadingFailed : RemoteDataType -> Http.Error -> Model -> ( Model, List (Cmd StoreMsg) )
handleLoadingFailed dt err model =
    let
        niceMsg =
            userFacingErrorMessage err
    in
    ( { model
        | dataStore = handleFailed dt niceMsg model.dataStore
        , notifications = Notif.createLoadingFailed niceMsg model.notifications
      }
    , []
    )


updateNewData : Bool -> RemoteDataType -> RawResponse -> Model -> Model
updateNewData ignorePageInfo dt rawResp model =
    case dt of
        OutgoingSms ->
            { model | dataStore = updateSmsOutbounds ignorePageInfo model.dataStore (dataFromResp decodeSmsOutbound rawResp) rawResp.next }

        IncomingSms ->
            { model | dataStore = updateSmsInbounds ignorePageInfo model.dataStore (dataFromResp decodeSmsInbound rawResp) rawResp.next }

        Groups _ ->
            { model | dataStore = updateGroups ignorePageInfo model.dataStore (dataFromResp decodeRecipientGroup rawResp) rawResp.next }

        Contacts _ ->
            { model | dataStore = updateRecipients ignorePageInfo model.dataStore (dataFromResp decodeRecipient rawResp) rawResp.next }

        Keywords _ ->
            { model | dataStore = updateKeywords ignorePageInfo model.dataStore (dataFromResp decodeKeyword rawResp) rawResp.next }

        ElvantoGroups ->
            { model | dataStore = updateElvantoGroups ignorePageInfo model.dataStore (dataFromResp decodeElvantoGroup rawResp) rawResp.next }

        UserProfiles ->
            { model | dataStore = updateUserProfiles ignorePageInfo model.dataStore (dataFromResp decodeUserProfile rawResp) rawResp.next }

        ScheduledSms ->
            { model | dataStore = updateQueuedSms ignorePageInfo model.dataStore (dataFromResp decodeQueuedSms rawResp) rawResp.next }

        Users ->
            { model | dataStore = updateUsers ignorePageInfo model.dataStore (dataFromResp decodeUser rawResp) rawResp.next }


updateStatus : Bool -> Maybe String -> RL.RemoteList a -> RL.RemoteList a
updateStatus ignorePageInfo next rl =
    case ignorePageInfo of
        True ->
            rl

        False ->
            case next of
                Nothing ->
                    RL.FinalPageReceived <| RL.toList rl

                _ ->
                    setLoadDataStatusHelp <| rl



-- Helpers


updateSmsOutbounds : Bool -> DataStore -> List SmsOutbound -> Maybe String -> DataStore
updateSmsOutbounds ignorePageInfo ds sms next =
    { ds
        | outboundSms =
            RL.apply (mergeItems sms >> List.sortBy compareByTS >> List.reverse) ds.outboundSms
                |> updateStatus ignorePageInfo next
    }


updateSmsInbounds : Bool -> DataStore -> List SmsInbound -> Maybe String -> DataStore
updateSmsInbounds ignorePageInfo ds newSms next =
    { ds
        | inboundSms =
            RL.apply (mergeItems newSms >> sortByTimeReceived) ds.inboundSms
                |> updateStatus ignorePageInfo next
    }


updateQueuedSms : Bool -> DataStore -> List QueuedSms -> Maybe String -> DataStore
updateQueuedSms ignorePageInfo ds newSms next =
    { ds
        | queuedSms =
            RL.apply (List.sortBy compareByT2S << mergeItems newSms) ds.queuedSms
                |> updateStatus ignorePageInfo next
    }


updateKeywords : Bool -> DataStore -> List Keyword -> Maybe String -> DataStore
updateKeywords ignorePageInfo ds keywords next =
    { ds
        | keywords =
            RL.apply (List.sortBy .keyword << mergeItems keywords) ds.keywords
                |> updateStatus ignorePageInfo next
    }


updateRecipients : Bool -> DataStore -> List Recipient -> Maybe String -> DataStore
updateRecipients ignorePageInfo dataStore newRecipients next =
    { dataStore
        | recipients =
            RL.apply (List.sortBy .last_name << mergeItems newRecipients) dataStore.recipients
                |> updateStatus ignorePageInfo next
    }


updateGroups : Bool -> DataStore -> List RecipientGroup -> Maybe String -> DataStore
updateGroups ignorePageInfo ds groups next =
    { ds
        | groups =
            RL.apply (List.sortBy .name << mergeItems groups) ds.groups
                |> updateStatus ignorePageInfo next
    }


updateUserProfiles : Bool -> DataStore -> List UserProfile -> Maybe String -> DataStore
updateUserProfiles ignorePageInfo dataStore profiles next =
    { dataStore
        | userprofiles =
            RL.apply (List.sortBy (.email << .user) << mergeItems profiles) dataStore.userprofiles
                |> updateStatus ignorePageInfo next
    }


updateElvantoGroups : Bool -> DataStore -> List ElvantoGroup -> Maybe String -> DataStore
updateElvantoGroups ignorePageInfo ds newGroups next =
    { ds
        | elvantoGroups =
            RL.apply (List.sortBy .name << mergeItems newGroups) ds.elvantoGroups
                |> updateStatus ignorePageInfo next
    }


updateUsers : Bool -> DataStore -> List User -> Maybe String -> DataStore
updateUsers ignorePageInfo ds newUsers next =
    { ds
        | users =
            RL.apply (List.sortBy .email << mergeItems newUsers) ds.users
                |> updateStatus ignorePageInfo next
    }



-- merge new items with existing


mergeItems : List { a | pk : Int } -> List { a | pk : Int } -> List { a | pk : Int }
mergeItems newItems existingItems =
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


type alias ErrResp =
    { status : String
    , error : String
    }


decodeErrResp : Decode.Decoder ErrResp
decodeErrResp =
    decode ErrResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


userFacingErrorMessage : Http.Error -> String
userFacingErrorMessage err =
    case err of
        Http.BadUrl _ ->
            "That's a bad URL. Sorry."

        Http.NetworkError ->
            "Looks like there may be something wrong with your internet connection :("

        Http.BadStatus r ->
            r.body
                |> Decode.decodeString decodeErrResp
                |> Result.withDefault { status = "", error = "Something went wrong there. Sorry. (" ++ r.body ++ ")" }
                |> .error

        Http.BadPayload msg _ ->
            "Something went wrong there. Sorry. (" ++ msg ++ ")"

        Http.Timeout ->
            "It took too long to reach the server..."
