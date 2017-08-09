module Store.DataTypes exposing (RemoteDataType(..), dt2Url, dt_from_page)

import Pages exposing (Page(..))
import Urls


type RemoteDataType
    = IncomingSms
    | OutgoingSms
    | Contacts (Maybe Int)
    | Groups (Maybe Int)
    | Keywords (Maybe String)
    | ScheduledSms
    | ElvantoGroups
    | UserProfiles
    | Users


dt2Url : RemoteDataType -> ( Bool, String )
dt2Url dt =
    case dt of
        IncomingSms ->
            ( False, Urls.api_in_log )

        OutgoingSms ->
            ( False, Urls.api_out_log )

        Contacts maybePk ->
            case maybePk of
                Just pk ->
                    ( True, Urls.api_recipients maybePk )

                Nothing ->
                    ( False, Urls.api_recipients maybePk )

        Groups maybePk ->
            case maybePk of
                Just pk ->
                    ( True, Urls.api_recipient_groups maybePk )

                Nothing ->
                    ( False, Urls.api_recipient_groups maybePk )

        Keywords maybeK ->
            case maybeK of
                Nothing ->
                    ( False, Urls.api_keywords maybeK )

                Just k ->
                    ( True, Urls.api_keywords maybeK )

        ScheduledSms ->
            ( False, Urls.api_queued_smss )

        ElvantoGroups ->
            ( False, Urls.api_elvanto_groups )

        UserProfiles ->
            ( False, Urls.api_user_profiles )

        Users ->
            ( False, Urls.api_users )


dt_from_page : Page -> List RemoteDataType
dt_from_page p =
    case p of
        OutboundTable ->
            [ OutgoingSms ]

        InboundTable ->
            [ IncomingSms ]

        GroupTable _ ->
            [ Groups Nothing ]

        GroupComposer _ ->
            [ Groups Nothing ]

        RecipientTable _ ->
            [ Contacts Nothing ]

        KeywordTable _ ->
            [ Keywords Nothing ]

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
            [ IncomingSms, Keywords Nothing ]

        FirstRun _ ->
            []

        AccessDenied ->
            []

        SendAdhoc _ ->
            [ Contacts Nothing ]

        SendGroup _ ->
            [ Groups Nothing ]

        GroupForm _ maybepK ->
            [ Groups Nothing, Groups maybepK ]

        ContactForm _ maybePk ->
            case maybePk of
                Nothing ->
                    [ Contacts maybePk ]

                Just _ ->
                    [ IncomingSms, Contacts maybePk, Contacts Nothing ]

        KeywordForm _ maybeK ->
            [ Keywords maybeK, Keywords Nothing, Groups Nothing, Users ]

        Error404 ->
            []

        Home ->
            []

        SiteConfigForm _ ->
            [ Groups Nothing ]

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
