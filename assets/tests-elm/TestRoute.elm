module TestRoute exposing (suite)

import Expect
import Fuzz as F
import List.Extra exposing (uncons)
import Models exposing (Model)
import Navigation
import Pages exposing (FabOnlyPage(..), Page(..), initSendAdhoc, initSendGroup)
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Pages.FirstRun.Model exposing (initialFirstRunModel)
import Pages.GroupComposer.Model exposing (initialGroupComposerModel)
import Pages.GroupForm.Model exposing (initialGroupFormModel)
import Pages.KeywordForm.Model exposing (initialKeywordFormModel)
import Route exposing (page2loc, route)
import Test exposing (Test, describe, fuzz, test)
import UrlParser as Url


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
    fuzz F.int "Edit Pages" (\pk -> Expect.equal (page pk) (page pk |> page2str2page))


easyPages : List Page
easyPages =
    [ Home
    , OutboundTable
    , InboundTable
    , GroupTable True
    , GroupTable False
    , GroupComposer initialGroupComposerModel
    , RecipientTable True
    , RecipientTable False
    , KeywordTable True
    , KeywordTable False
    , ElvantoImport
    , Wall
    , Curator
    , UserProfileTable
    , ScheduledSmsTable
    , KeyRespTable False True "test"
    , KeyRespTable False False "test"
    , FirstRun initialFirstRunModel
    , initSendAdhoc Nothing Nothing
    , initSendAdhoc (Just "test") Nothing
    , initSendAdhoc Nothing (Just [ 1 ])
    , initSendAdhoc (Just "test") (Just [ 1 ])
    , initSendGroup Nothing Nothing
    , initSendGroup (Just "test") Nothing
    , initSendGroup Nothing (Just 1)
    , initSendGroup (Just "test") (Just 1)
    , SiteConfigForm Nothing
    , GroupForm initialGroupFormModel Nothing
    , GroupForm initialGroupFormModel <| Just 1
    , FabOnlyPage <| Help
    , FabOnlyPage <| CreateAllGroup
    , ContactForm initialContactFormModel Nothing
    , ContactForm initialContactFormModel <| Just 1
    , KeywordForm initialKeywordFormModel Nothing
    , KeywordForm initialKeywordFormModel <| Just "test"
    , FabOnlyPage <| ContactImport
    , FabOnlyPage <| ApiSetup
    , FabOnlyPage <| EditResponses
    ]


editPages : List (Int -> Page)
editPages =
    [ FabOnlyPage << EditUserProfile
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
                    "?" ++ (s |> Tuple.second |> String.join "?")
    in
    Navigation.Location url "" "" "" "" "" path search "" "" ""
