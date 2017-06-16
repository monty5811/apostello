module Pages.Forms.UserProfile.Messages exposing (UserProfileFormMsg(..))

import Data.User exposing (UserProfile)


type UserProfileFormMsg
    = UpdateApproved (Maybe UserProfile)
    | UpdateMessageCostLimit String
    | UpdateCanSeeGroups (Maybe UserProfile)
    | UpdateCanSeeContactNames (Maybe UserProfile)
    | UpdateCanSeeKeywords (Maybe UserProfile)
    | UpdateCanSeeOutgoing (Maybe UserProfile)
    | UpdateCanSeeIncoming (Maybe UserProfile)
    | UpdateCanSendSms (Maybe UserProfile)
    | UpdateCanSeeContactNums (Maybe UserProfile)
    | UpdateCanImport (Maybe UserProfile)
    | UpdateCanArchive (Maybe UserProfile)
