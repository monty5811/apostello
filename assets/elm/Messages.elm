module Messages exposing (..)

import Http
import Models.Apostello
    exposing
        ( ElvantoGroup
        , Keyword
        , Recipient
        , RecipientSimple
        , RecipientGroup
        , SmsInbound
        , SmsOutbound
        , UserProfile
        )
import Models.FirstRun exposing (FirstRunResp)
import Models.Remote exposing (RemoteDataType, RawResponse)
import Navigation
import Time


-- MESSAGES


type Msg
    = LoadData
    | ReceiveRawResp RemoteDataType (Result Http.Error RawResponse)
    | UrlChange Navigation.Location
    | NewUrl String
    | UpdateTableFilter String
    | ElvantoMsg ElvantoMsg
    | InboundTableMsg InboundTableMsg
    | RecipientTableMsg RecipientTableMsg
    | KeywordTableMsg KeywordTableMsg
    | GroupTableMsg GroupTableMsg
    | GroupComposerMsg GroupComposerMsg
    | GroupMemberSelectMsg GroupMemberSelectMsg
    | WallMsg WallMsg
    | UserProfileTableMsg UserProfileTableMsg
    | ScheduledSmsTableMsg ScheduledSmsTableMsg
    | KeyRespTableMsg KeyRespTableMsg
    | FirstRunMsg FirstRunMsg
    | SendAdhocMsg SendAdhocMsg
    | SendGroupMsg SendGroupMsg
    | FabMsg FabMsg
    | NotificationMsg NotificationMsg
    | CurrentTime Time.Time
    | LoadDataStore String
    | Nope


type NotificationMsg
    = RemoveNotification Int


type FabMsg
    = ArchiveItem String String Bool
    | ReceiveArchiveResp String (Result Http.Error Bool)
    | ToggleFabView


type SendAdhocMsg
    = UpdateContent String
    | UpdateDate String
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ToggleSelectAdhocModal Bool
    | ToggleSelectedContact Int
    | UpdateAdhocFilter String


type SendGroupMsg
    = UpdateSGContent String
    | UpdateSGDate String
    | PostSGForm
    | ReceiveSGFormResp (Result Http.Error { body : String, code : Int })
    | ToggleSelectGroupModal Bool
    | SelectGroup Int
    | UpdateGroupFilter String


type FirstRunMsg
    = UpdateAdminEmailField String
    | UpdateAdminPass1Field String
    | UpdateAdminPass2Field String
    | UpdateTestEmailToField String
    | UpdateTestEmailBodyField String
    | UpdateTestSmsToField String
    | UpdateTestSmsBodyField String
    | SendTestEmail
    | SendTestSms
    | CreateAdminUser
    | ReceiveCreateAdminUser (Result Http.Error FirstRunResp)
    | ReceiveSendTestSms (Result Http.Error FirstRunResp)
    | ReceiveSendTestEmail (Result Http.Error FirstRunResp)


type ElvantoMsg
    = ToggleGroupSync ElvantoGroup
    | ReceiveToggleGroupSync (Result Http.Error ElvantoGroup)
    | PullGroups
    | FetchGroups
    | ReceiveButtonResp (Result Http.Error Bool)


type InboundTableMsg
    = ReprocessSms Int
    | ReceiveReprocessSms (Result Http.Error SmsInbound)


type GroupMemberSelectMsg
    = UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | ToggleMembership RecipientGroup RecipientSimple
    | ReceiveToggleMembership (Result Http.Error RecipientGroup)


type WallMsg
    = ToggleWallDisplay Bool Int
    | ReceiveToggleWallDisplay (Result Http.Error SmsInbound)


type UserProfileTableMsg
    = ToggleField UserProfile
    | ReceiveToggleProfile (Result Http.Error UserProfile)


type RecipientTableMsg
    = ToggleRecipientArchive Bool Int
    | ReceiveRecipientToggleArchive (Result Http.Error Recipient)


type KeywordTableMsg
    = ToggleKeywordArchive Bool String
    | ReceiveToggleKeywordArchive (Result Http.Error Keyword)


type GroupTableMsg
    = ToggleGroupArchive Bool Int
    | ReceiveToggleGroupArchive (Result Http.Error RecipientGroup)


type GroupComposerMsg
    = UpdateQueryString String


type ScheduledSmsTableMsg
    = CancelSms Int
    | ReceiveCancelSms (Result Http.Error Bool)


type KeyRespTableMsg
    = ToggleInboundSmsArchive Bool Int
    | ToggleInboundSmsDealtWith Bool Int
    | ReceiveToggleInboundSmsArchive (Result Http.Error SmsInbound)
    | ReceiveToggleInboundSmsDealtWith (Result Http.Error SmsInbound)
    | ArchiveAllButtonClick String
    | ArchiveAllCheckBoxClick
    | ReceiveArchiveAllResp (Result Http.Error Bool)
