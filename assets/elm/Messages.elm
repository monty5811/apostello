module Messages exposing (..)

import Http
import Models exposing (..)
import Time


-- MESSAGES


type Msg
    = LoadData LoadingStatus
    | ReceiveRawResp (Result Http.Error RawResponse)
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
    | FabMsg FabMsg
    | NotificationMsg NotificationMsg
    | CurrentTime Time.Time


type NotificationMsg
    = NewNotification NotificationType String
    | RemoveNotification Notification
    | CleanOldNotifications Time.Time


type FabMsg
    = ArchiveItem
    | ReceiveArchiveResp (Result Http.Error Bool)
    | ToggleFabView


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
    | ToggleMembership RecipientSimple
    | ReceiveToggleMembership (Result Http.Error RecipientGroup)


type WallMsg
    = ToggleWallDisplay Bool Int
    | ReceiveToggleWallDisplay (Result Http.Error SmsInboundSimple)


type UserProfileTableMsg
    = ToggleField UserProfile
    | ReceiveToggleProfile (Result Http.Error UserProfile)


type RecipientTableMsg
    = ToggleRecipientArchive Bool Int
    | ReceiveRecipientToggleArchive (Result Http.Error Recipient)


type KeywordTableMsg
    = ToggleKeywordArchive Bool Int
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
