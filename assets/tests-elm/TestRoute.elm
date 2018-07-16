module TestRoute exposing (suite)

import Expect
import List.Extra exposing (uncons)
import Navigation
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.UserProfile as UPF
import Pages.GroupComposer as GC
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


testPage : Page -> Test
testPage page =
    test (toString page) <| \() -> Expect.equal page (page2str2page page)


suite : Test
suite =
    describe "Routing Test Suite" (List.map testPage pages)


pages : List Page
pages =
    [ Home
    , OutboundTable
    , InboundTable
    , GroupTable True
    , GroupTable False
    , GroupComposer GC.initialModel
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
    , FirstRun FR.initialModel
    , initSendAdhoc Nothing Nothing
    , initSendAdhoc (Just "test") Nothing
    , initSendAdhoc Nothing (Just [ 1 ])
    , initSendAdhoc (Just "test") (Just [ 1 ])
    , initSendGroup Nothing Nothing
    , initSendGroup (Just "test") Nothing
    , initSendGroup Nothing (Just 1)
    , initSendGroup (Just "test") (Just 1)
    , SiteConfigForm Nothing
    , GroupForm GF.initialModel Nothing
    , GroupForm GF.initialModel <| Just 1
    , Help
    , Usage
    , CreateAllGroup ""
    , ContactForm CF.initialModel Nothing
    , ContactForm CF.initialModel <| Just 1
    , KeywordForm KF.initialModel Nothing
    , KeywordForm KF.initialModel <| Just "test"
    , ContactImport CI.initialModel
    , ApiSetup Nothing
    , DefaultResponsesForm Nothing
    , UserProfileForm UPF.initialModel 1
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
