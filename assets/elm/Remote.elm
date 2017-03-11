module Remote exposing (maybeFetchData, fetchData, increasePageSize)

import Http
import Json.Decode as Decode
import Messages exposing (..)
import Models exposing (RemoteDataType(..), RawResponse)
import Pages exposing (Page(..), FabOnlyPage(..))
import Regex
import Urls


maybeFetchData : Page -> Cmd Msg
maybeFetchData dataToFetch =
    dataToFetch
        |> dt_url_from_page
        |> List.map fetchData
        |> Cmd.batch


fetchData : ( RemoteDataType, String ) -> Cmd Msg
fetchData ( dt, dataUrl ) =
    makeRequest dataUrl
        |> Http.send (ReceiveRawResp dt)


dt_url_from_page : Page -> List ( RemoteDataType, String )
dt_url_from_page p =
    case p of
        OutboundTable ->
            [ ( OutgoingSms, Urls.smsOutbounds ) ]

        InboundTable ->
            [ ( IncomingSms, Urls.smsInbounds ) ]

        GroupTable False ->
            [ ( Groups, Urls.groups ) ]

        GroupTable True ->
            [ ( Groups, Urls.groupsArchive ) ]

        GroupComposer ->
            [ ( Groups, Urls.groups ) ]

        RecipientTable False ->
            [ ( Contacts, Urls.recipients ) ]

        RecipientTable True ->
            [ ( Contacts, Urls.recipientsArchive ) ]

        KeywordTable False ->
            [ ( Keywords, Urls.keywords ) ]

        KeywordTable True ->
            [ ( Keywords, Urls.keywordsArchive ) ]

        ElvantoImport ->
            [ ( ElvantoGroups_, Urls.elvantoGroups ) ]

        Wall ->
            [ ( IncomingSms, Urls.smsInbounds ) ]

        Curator ->
            [ ( IncomingSms, Urls.smsInbounds ) ]

        UserProfileTable ->
            [ ( UserProfiles, Urls.userProfiles ) ]

        ScheduledSmsTable ->
            [ ( ScheduledSms, Urls.queuedSmss ) ]

        KeyRespTable False k ->
            [ ( IncomingSms, Urls.smsInboundsKeyword k )
            , ( Keywords, Urls.keywords )
            , ( Keywords, Urls.keywordsArchive )
            ]

        KeyRespTable True k ->
            [ ( IncomingSms, Urls.smsInboundsKeywordArchive k )
            , ( Keywords, Urls.keywords )
            , ( Keywords, Urls.keywordsArchive )
            ]

        FirstRun ->
            []

        AccessDenied ->
            []

        SendAdhoc _ _ ->
            [ ( Contacts, Urls.recipients ) ]

        SendGroup _ _ ->
            [ ( Groups, Urls.groups ) ]

        EditGroup _ ->
            [ ( Groups, Urls.groups )
            , ( Groups, Urls.groupsArchive )
            ]

        EditContact _ ->
            [ ( IncomingSms, Urls.smsInbounds )
            , ( Contacts, Urls.recipients )
            , ( Contacts, Urls.recipientsArchive )
            ]

        Error404 ->
            []

        Home ->
            []

        FabOnlyPage fabPage ->
            case fabPage of
                Help ->
                    []

                NewGroup ->
                    []

                CreateAllGroup ->
                    []

                NewContact ->
                    []

                NewKeyword ->
                    []

                EditKeyword _ ->
                    [ ( Keywords, Urls.keywords ), ( Keywords, Urls.keywordsArchive ) ]

                ContactImport ->
                    []

                ApiSetup ->
                    []

                EditUserProfile _ ->
                    []

                EditSiteConfig ->
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
    case Regex.contains (Regex.regex "page_size") url of
        True ->
            Regex.replace (Regex.AtMost 1) (Regex.regex "page=2&page_size=100$") (\_ -> "page_size=1000") url

        False ->
            Regex.replace (Regex.AtMost 1) (Regex.regex "page=2$") (\_ -> "page_size=100") url
