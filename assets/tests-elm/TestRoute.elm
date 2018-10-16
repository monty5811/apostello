module TestRoute exposing (suite)

import Expect
import List.Extra exposing (uncons)
import Navigation
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.Curator as C
import Pages.DeletePanel as DP
import Pages.ElvantoImport as EI
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAG
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UPF
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.InboundTable as IT
import Pages.KeyRespTable as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.UserProfileTable as UPT
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
    , OutboundTable OT.initialModel
    , InboundTable IT.initialModel
    , GroupTable GT.initialModel True
    , GroupTable GT.initialModel False
    , GroupComposer GC.initialModel
    , RecipientTable RT.initialModel True
    , RecipientTable RT.initialModel False
    , KeywordTable KT.initialModel True
    , KeywordTable KT.initialModel False
    , ElvantoImport EI.initialModel
    , Wall
    , Curator C.initialModel
    , UserProfileTable UPT.initialModel
    , ScheduledSmsTable SST.initialModel
    , KeyRespTable KRT.initialModel True "test"
    , KeyRespTable KRT.initialModel False "test"
    , FirstRun FR.initialModel
    , initSendAdhoc Nothing Nothing
    , initSendAdhoc (Just "test") Nothing
    , initSendAdhoc Nothing (Just [ 1 ])
    , initSendAdhoc (Just "test") (Just [ 1 ])
    , initSendGroup Nothing Nothing
    , initSendGroup (Just "test") Nothing
    , initSendGroup Nothing (Just 1)
    , initSendGroup (Just "test") (Just 1)
    , SiteConfigForm SCF.initialModel
    , GroupForm <| GF.initialModel Nothing
    , GroupForm <| GF.initialModel <| Just 1
    , Help
    , Usage
    , CreateAllGroup CAG.initialModel
    , ContactForm <| CF.initialModel Nothing
    , ContactForm <| CF.initialModel <| Just 1
    , KeywordForm <| KF.initialModel Nothing
    , KeywordForm <| KF.initialModel <| Just "test"
    , ContactImport CI.initialModel
    , ApiSetup Nothing
    , DefaultResponsesForm DRF.initialModel
    , UserProfileForm (UPF.initialModel 1)
    , DeletePanel DP.initialModel
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
