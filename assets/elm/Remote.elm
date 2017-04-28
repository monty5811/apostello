module Remote exposing (maybeFetchData, fetchData, increasePageSize)

import Http
import Json.Decode as Decode
import Messages exposing (Msg(..))
import Models.Remote exposing (RemoteDataType(..), RawResponse)
import Pages exposing (Page(..), FabOnlyPage(..))
import String.Extra
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

        GroupTable _ ->
            [ ( Groups, Urls.groups ) ]

        GroupComposer ->
            [ ( Groups, Urls.groups ) ]

        RecipientTable _ ->
            [ ( Contacts, Urls.recipients ) ]

        KeywordTable _ ->
            [ ( Keywords, Urls.keywords ) ]

        ElvantoImport ->
            [ ( ElvantoGroups, Urls.elvantoGroups ) ]

        Wall ->
            [ ( IncomingSms, Urls.smsInbounds ) ]

        Curator ->
            [ ( IncomingSms, Urls.smsInbounds ) ]

        UserProfileTable ->
            [ ( UserProfiles, Urls.userProfiles ) ]

        ScheduledSmsTable ->
            [ ( ScheduledSms, Urls.queuedSmss ) ]

        KeyRespTable False _ ->
            [ ( IncomingSms, Urls.smsInbounds )
            , ( Keywords, Urls.keywords )
            ]

        KeyRespTable True _ ->
            [ ( IncomingSms, Urls.smsInbounds )
            , ( Keywords, Urls.keywords )
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
            ]

        EditContact _ ->
            [ ( IncomingSms, Urls.smsInbounds )
            , ( Contacts, Urls.recipients )
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
                    [ ( Keywords, Urls.keywords ) ]

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
    case String.contains "page_size" url of
        True ->
            String.Extra.replace "page=2&page_size=100$" "page_size=1000" url

        False ->
            String.Extra.replace "page=2$" "page_size=100" url
