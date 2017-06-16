module Store.DataTypes exposing (RemoteDataType(..), dt2Url, dt_from_page)

import Pages exposing (Page(..))
import Urls


type RemoteDataType
    = IncomingSms
    | OutgoingSms
    | Contacts
    | Groups
    | Keywords
    | ScheduledSms
    | ElvantoGroups
    | UserProfiles
    | Users


dt2Url : RemoteDataType -> String
dt2Url dt =
    case dt of
        IncomingSms ->
            Urls.api_in_log

        OutgoingSms ->
            Urls.api_out_log

        Contacts ->
            Urls.api_recipients

        Groups ->
            Urls.api_recipient_groups

        Keywords ->
            Urls.api_keywords

        ScheduledSms ->
            Urls.api_queued_smss

        ElvantoGroups ->
            Urls.api_elvanto_groups

        UserProfiles ->
            Urls.api_user_profiles

        Users ->
            Urls.api_users


dt_from_page : Page -> List RemoteDataType
dt_from_page p =
    case p of
        OutboundTable ->
            [ OutgoingSms ]

        InboundTable ->
            [ IncomingSms ]

        GroupTable _ ->
            [ Groups ]

        GroupComposer _ ->
            [ Groups ]

        RecipientTable _ ->
            [ Contacts ]

        KeywordTable _ ->
            [ Keywords ]

        ElvantoImport ->
            [ ElvantoGroups ]

        Wall ->
            [ IncomingSms ]

        Curator ->
            [ IncomingSms ]

        UserProfileTable ->
            [ UserProfiles ]

        ScheduledSmsTable ->
            [ ScheduledSms ]

        KeyRespTable _ _ _ ->
            [ IncomingSms, Keywords ]

        FirstRun _ ->
            []

        AccessDenied ->
            []

        SendAdhoc _ ->
            [ Contacts ]

        SendGroup _ ->
            [ Groups ]

        GroupForm _ _ ->
            [ Groups ]

        ContactForm _ maybePk ->
            case maybePk of
                Nothing ->
                    [ Contacts ]

                Just _ ->
                    [ IncomingSms, Contacts ]

        KeywordForm _ _ ->
            [ Keywords, Groups, Users ]

        Error404 ->
            []

        Home ->
            []

        SiteConfigForm _ ->
            [ Groups ]

        DefaultResponsesForm _ ->
            []

        CreateAllGroup _ ->
            []

        Usage ->
            []

        Help ->
            []

        UserProfileForm _ _ ->
            [ UserProfiles ]

        ContactImport _ ->
            []

        ApiSetup _ ->
            []
