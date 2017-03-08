module TestRoute exposing (suite)

import Expect
import List.Extra exposing (uncons)
import Models exposing (..)
import Navigation
import Route exposing (..)
import Test exposing (..)
import UrlParser as Url
import Fuzz as F


page2str2page : Page -> Page
page2str2page page =
    page
        |> page2loc
        |> loc
        |> Url.parsePath route
        |> Maybe.withDefault Error404


testEasyPage : Page -> Test
testEasyPage page =
    test (toString page) <| \() -> Expect.equal page (page2str2page page)


suite : Test
suite =
    describe "Routing Test Suite"
        [ describe "Easy Pages" (List.map testEasyPage easyPages)
        , describe "Edit Pages (pk)" (List.map fuzzEditPage editPages)
        ]


fuzzEditPage : (Int -> Page) -> Test
fuzzEditPage page =
    fuzz (F.int) "Edit Pages" (\pk -> Expect.equal (page pk) (page pk |> page2str2page))


easyPages : List Page
easyPages =
    [ Home
    , OutboundTable
    , InboundTable
    , GroupTable True
    , GroupTable False
    , GroupComposer
    , RecipientTable True
    , RecipientTable False
    , KeywordTable True
    , KeywordTable False
    , ElvantoImport
    , Wall
    , Curator
    , UserProfileTable
    , ScheduledSmsTable
    , KeyRespTable True "test"
    , KeyRespTable False "test"
    , FirstRun
    , SendAdhoc Nothing Nothing
    , SendAdhoc (Just "test") Nothing
    , SendAdhoc Nothing (Just [ 1 ])
    , SendAdhoc (Just "test") (Just [ 1 ])
    , SendGroup Nothing Nothing
    , SendGroup (Just "test") Nothing
    , SendGroup Nothing (Just 1)
    , SendGroup (Just "test") (Just 1)
    , FabOnlyPage <| Help
    , FabOnlyPage <| NewGroup
    , FabOnlyPage <| CreateAllGroup
    , FabOnlyPage <| NewContact
    , FabOnlyPage <| NewKeyword
    , FabOnlyPage <| EditKeyword "test"
    , FabOnlyPage <| ContactImport
    , FabOnlyPage <| ApiSetup
    , FabOnlyPage <| EditSiteConfig
    , FabOnlyPage <| EditResponses
    ]


editPages : List (Int -> Page)
editPages =
    [ EditGroup
    , EditContact
    , FabOnlyPage << EditUserProfile
    ]


loc : String -> Navigation.Location
loc url =
    let
        splitUrl =
            String.split "?" url

        path =
            splitUrl |> List.head |> Maybe.withDefault url

        maybeSearch =
            splitUrl |> uncons

        search =
            case maybeSearch of
                Nothing ->
                    ""

                Just s ->
                    "?"
                        ++ (String.join "?" (Tuple.second s))
    in
        Navigation.Location url "" "" "" "" "" path search "" "" ""
