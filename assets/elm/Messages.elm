module Messages exposing (..)

import Http
import Models exposing (..)
import Time


-- MESSAGES


type Msg
    = LoadData LoadingStatus
    | UpdateTableFilter String
    | ElvantoMsg ElvantoMsg
    | InboundTableMsg InboundTableMsg
    | OutboundTableMsg OutboundTableMsg
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
    = LoadElvantoResp (Result Http.Error (ApostelloResponse ElvantoGroup))
    | ToggleGroupSync ElvantoGroup
    | ReceiveToggleGroupSync (Result Http.Error ElvantoGroup)
    | PullGroups
    | FetchGroups
    | ReceiveButtonResp (Result Http.Error Bool)


type InboundTableMsg
    = LoadInboundTableResp (Result Http.Error (ApostelloResponse SmsInbound))
    | ReprocessSms Int
    | ReceiveReprocessSms (Result Http.Error SmsInbound)


type GroupMemberSelectMsg
    = LoadGroupMemberSelectResp (Result Http.Error RecipientGroup)
    | UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | ToggleMembership RecipientSimple
    | ReceiveToggleMembership (Result Http.Error RecipientGroup)


type WallMsg
    = LoadWallResp (Result Http.Error (ApostelloResponse SmsInboundSimple))
    | ToggleWallDisplay Bool Int
    | ReceiveToggleWallDisplay (Result Http.Error SmsInboundSimple)


type UserProfileTableMsg
    = LoadUserProfileTableResp (Result Http.Error (ApostelloResponse UserProfile))
    | ToggleField UserProfile
    | ReceiveToggleProfile (Result Http.Error UserProfile)


type RecipientTableMsg
    = LoadRecipientTableResp (Result Http.Error (ApostelloResponse Recipient))
    | ToggleRecipientArchive Bool Int
    | ReceiveRecipientToggleArchive (Result Http.Error Recipient)


type KeywordTableMsg
    = LoadKeywordTableResp (Result Http.Error (ApostelloResponse Keyword))
    | ToggleKeywordArchive Bool Int
    | ReceiveToggleKeywordArchive (Result Http.Error Keyword)


type GroupTableMsg
    = LoadGroupTableResp (Result Http.Error (ApostelloResponse RecipientGroup))
    | ToggleGroupArchive Bool Int
    | ReceiveToggleGroupArchive (Result Http.Error RecipientGroup)


type OutboundTableMsg
    = LoadOutboundTableResp (Result Http.Error (ApostelloResponse SmsOutbound))


type GroupComposerMsg
    = UpdateQueryString String
    | LoadGroupComposerResp (Result Http.Error (ApostelloResponse RecipientGroup))


type ScheduledSmsTableMsg
    = LoadScheduledSmsTableResp (Result Http.Error (ApostelloResponse QueuedSms))
    | CancelSms Int
    | ReceiveCancelSms (Result Http.Error Bool)


type KeyRespTableMsg
    = LoadKeyRespTableResp (Result Http.Error (ApostelloResponse SmsInbound))
    | ToggleInboundSmsArchive Bool Int
    | ToggleInboundSmsDealtWith Bool Int
    | ReceiveToggleInboundSmsArchive (Result Http.Error SmsInbound)
    | ReceiveToggleInboundSmsDealtWith (Result Http.Error SmsInbound)
