module Data.Request exposing (..)

import Data.ElvantoGroup exposing (ElvantoGroup)
import Data.Recipient exposing (RecipientSimple)
import Data.RecipientGroup exposing (RecipientGroup)
import Http
import Json.Decode as Decode
import Pages exposing (FabOnlyPage(..), Page(..))
import Regex
import Urls


-- Models


type alias RawResponse =
    { body : String
    , next : Maybe String
    }


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


type RemoteList a
    = NotAsked (List a)
    | WaitingForFirstResp (List a)
    | WaitingForPage (List a)
    | FinalPageReceived (List a)
    | WaitingOnRefresh (List a)
    | RespFailed String (List a)



-- Messages


type StoreMsg
    = LoadData
    | LoadDataStore String
    | ReceiveRawResp RemoteDataType (Result Http.Error RawResponse)
    | ToggleGroupMembership RecipientGroup RecipientSimple
    | ReceiveToggleGroupMembership (Result Http.Error RecipientGroup)
    | ToggleElvantoGroupSync ElvantoGroup
    | ReceiveToggleElvantoGroupSync (Result Http.Error ElvantoGroup)



--


dataFromResp : Decode.Decoder a -> RawResponse -> List a
dataFromResp decoder rawResp =
    rawResp.body
        |> Decode.decodeString (Decode.field "results" (Decode.list decoder))
        |> Result.withDefault []


itemFromResp : a -> Decode.Decoder a -> RawResponse -> a
itemFromResp defaultCallback decoder rawResp =
    rawResp.body
        |> Decode.decodeString decoder
        |> Result.withDefault defaultCallback


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

        FabOnlyPage fabPage ->
            case fabPage of
                Help ->
                    []

                CreateAllGroup ->
                    []

                ContactImport ->
                    []

                ApiSetup ->
                    []

                EditUserProfile _ ->
                    []

                EditResponses ->
                    []


makeRequest : String -> Http.Request RawResponse
makeRequest dataUrl =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json" ]
        , url = dataUrl
        , body = Http.emptyBody
        , expect =
            Http.expectStringResponse (\resp -> Ok (extractRawResponse resp))
        , timeout = Nothing
        , withCredentials = True
        }


extractRawResponse : Http.Response String -> RawResponse
extractRawResponse resp =
    { body = resp.body
    , next = nextFromBody resp.body
    }


nextFromBody : String -> Maybe String
nextFromBody body =
    body
        |> Decode.decodeString (Decode.field "next" (Decode.maybe Decode.string))
        |> Result.withDefault Nothing



-- increase page size for next response


increasePageSize : String -> String
increasePageSize url =
    case String.contains "page_size" url of
        True ->
            Regex.replace Regex.All
                (Regex.regex "page=2&page_size=100$")
                (\_ -> "page_size=1000")
                url

        False ->
            Regex.replace Regex.All
                (Regex.regex "page=2$")
                (\_ -> "page_size=100")
                url
