module TestRoute exposing (suite)

import Expect
import Fuzz as F
import List.Extra exposing (uncons)
import Models exposing (Model)
import Navigation
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.FirstRun.Model exposing (initialFirstRunModel)
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.Forms.ContactImport.Model exposing (initialContactImportModel)
import Pages.Forms.Group.Model exposing (initialGroupFormModel)
import Pages.Forms.Keyword.Model exposing (initialKeywordFormModel)
import Pages.Forms.UserProfile.Model exposing (initialUserProfileFormModel)
import Pages.GroupComposer.Model exposing (initialGroupComposerModel)
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
    , Help
    , Usage
    , CreateAllGroup ""
    , ContactForm initialContactFormModel Nothing
    , ContactForm initialContactFormModel <| Just 1
    , KeywordForm initialKeywordFormModel Nothing
    , KeywordForm initialKeywordFormModel <| Just "test"
    , ContactImport initialContactImportModel
    , ApiSetup Nothing
    , DefaultResponsesForm Nothing
    , UserProfileForm initialUserProfileFormModel 1
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
