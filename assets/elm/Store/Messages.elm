module Store.Messages exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup)
import Data.Recipient exposing (RecipientSimple)
import Data.RecipientGroup exposing (RecipientGroup)
import Data.SmsInbound exposing (SmsInbound)
import Data.User exposing (UserProfile)
import Http
import Store.DataTypes exposing (RemoteDataType)
import Store.Model exposing (RawResponse)


type StoreMsg
    = LoadData
    | LoadDataStore String
    | ReceiveRawResp RemoteDataType (Result Http.Error RawResponse)
    | ToggleGroupMembership RecipientGroup RecipientSimple
    | ReceiveToggleGroupMembership (Result Http.Error RecipientGroup)
    | ToggleElvantoGroupSync ElvantoGroup
    | ReceiveToggleElvantoGroupSync (Result Http.Error ElvantoGroup)
    | CancelSms Int
    | ToggleRecipientArchive Bool Int
    | ToggleKeywordArchive Bool String
    | ToggleWallDisplay Bool Int
    | ToggleGroupArchive Bool Int
    | ToggleProfileField UserProfile
    | ReceiveToggleProfileField (Result Http.Error UserProfile)
    | ReceiveToggleWallDisplay (Result Http.Error SmsInbound)
    | ReceiveLazy (Result Http.Error { body : String, code : Int })
    | ReprocessSms Int
    | ToggleInboundSmsArchive Bool Int
    | ToggleInboundSmsDealtWith Bool Int
    | ReceiveToggleInboundSmsArchive (Result Http.Error SmsInbound)
    | ReceiveToggleInboundSmsDealtWith (Result Http.Error SmsInbound)
    | ReceiveReprocessSms (Result Http.Error SmsInbound)
