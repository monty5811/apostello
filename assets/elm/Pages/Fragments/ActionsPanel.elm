module Pages.Fragments.ActionsPanel exposing (update, view)

import Css
import Data exposing (Keyword)
import DjangoSend exposing (CSRFToken, archivePost)
import Helpers exposing (decodeAlwaysTrue)
import Html exposing (..)
import Html.Attributes as A exposing (href)
import Html.Events exposing (onClick)
import Http
import Messages exposing (..)
import Models exposing (Model)
import Navigation
import Pages exposing (Page(..))
import Pages.Forms.Contact as CF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import RemoteList as RL
import Route exposing (page2loc, spaLink)
import Store.Model exposing (DataStore)
import Urls as U


-- Update


update : ActionsPanelMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ArchiveItem redirectUrl url isArchived ->
            ( model, [ archiveItem model.settings.csrftoken redirectUrl url isArchived ] )

        ReceiveArchiveResp _ (Err _) ->
            ( model, [] )

        ReceiveArchiveResp url (Ok _) ->
            ( model, [ Navigation.load url ] )


archiveItem : CSRFToken -> String -> String -> Bool -> Cmd Msg
archiveItem csrf redirectUrl url isArchived =
    archivePost csrf url isArchived decodeAlwaysTrue
        |> Http.send (ActionsPanelMsg << ReceiveArchiveResp redirectUrl)



-- View


view : DataStore -> Page -> Bool -> List (Html Msg)
view ds page canArchive =
    fabLinks ds page canArchive


fabLinks : DataStore -> Page -> Bool -> List (Html Msg)
fabLinks ds page canArchive =
    case page of
        OutboundTable ->
            defaultLinks

        InboundTable ->
            [ incomingWall, wallCurator ]

        GroupTable viewingArchive ->
            let
                otherLink =
                    case viewingArchive of
                        True ->
                            groupsSpa

                        False ->
                            groupsArchiveSpa
            in
            [ newGroupSpa, otherLink ]

        GroupComposer _ ->
            [ newGroupSpa, groupsSpa, groupsArchiveSpa ]

        RecipientTable viewingArchive ->
            let
                otherLink =
                    case viewingArchive of
                        True ->
                            contactsSpa

                        False ->
                            contactArchiveSpa
            in
            [ newContactSpa, otherLink ]

        KeywordTable viewingArchive ->
            let
                otherLink =
                    case viewingArchive of
                        True ->
                            keywords

                        False ->
                            keywordArchive
            in
            [ newKeywordSpa, otherLink ]

        ElvantoImport ->
            defaultLinks

        Wall ->
            []

        Curator ->
            [ incomingWall ]

        UserProfileTable ->
            [ fabLink "/admin/auth/user/" "Admin: Users" ]

        ScheduledSmsTable ->
            defaultLinks

        KeyRespTable _ _ k ->
            let
                keyword =
                    ds.keywords
                        |> RL.toList
                        |> List.filter (\x -> x.keyword == k)
                        |> List.head
            in
            [ keywordEdit k
            , keywordCsv k
            , keywordResponsesSpa keyword
            , keywordArchiveResponsesSpa keyword
            ]

        FirstRun _ ->
            []

        Debug _ ->
            defaultLinks

        AccessDenied ->
            defaultLinks

        SendAdhoc _ ->
            defaultLinks

        SendGroup _ ->
            defaultLinks

        Error404 ->
            defaultLinks

        Home ->
            defaultLinks

        GroupForm _ maybePk ->
            case maybePk of
                Nothing ->
                    defaultLinks

                Just pk ->
                    let
                        isArchived =
                            ds.groups
                                |> RL.toList
                                |> List.filter (\x -> x.pk == pk)
                                |> List.head
                                |> Maybe.map .is_archived
                    in
                    [ archiveButton (GroupTable False)
                        (U.api_act_archive_group pk)
                        isArchived
                        canArchive
                    ]

        ContactForm _ maybePk ->
            case maybePk of
                Nothing ->
                    defaultLinks

                Just pk ->
                    let
                        isArchived =
                            ds.recipients
                                |> RL.toList
                                |> List.filter (\x -> x.pk == pk)
                                |> List.head
                                |> Maybe.map .is_archived
                    in
                    [ archiveButton (RecipientTable False)
                        (U.api_act_archive_recipient pk)
                        isArchived
                        canArchive
                    ]

        KeywordForm _ maybeK ->
            case maybeK of
                Nothing ->
                    defaultLinks

                Just k ->
                    let
                        keyword =
                            ds.keywords
                                |> RL.toList
                                |> List.filter (\x -> x.keyword == k)
                                |> List.head

                        isArchived =
                            keyword
                                |> Maybe.map .is_archived
                    in
                    [ keywordResponses keyword
                    , keywordArchiveResponses keyword
                    , archiveButton (KeywordTable False)
                        (U.api_act_archive_keyword k)
                        isArchived
                        canArchive
                    ]

        SiteConfigForm _ ->
            defaultLinks

        DefaultResponsesForm _ ->
            defaultLinks

        CreateAllGroup _ ->
            [ newGroupSpa, groupsSpa, groupsArchiveSpa ]

        Usage ->
            []

        Help ->
            defaultLinks

        UserProfileForm _ _ ->
            defaultLinks

        ContactImport _ ->
            defaultLinks

        ApiSetup _ ->
            defaultLinks


fabLink : String -> String -> Html Msg
fabLink uri linkText =
    a [ href uri, Css.flex_1, Css.btn, Css.btn_purple, Css.text_sm, Css.inline_block ] [ text linkText ]


fabSpaLink : Page -> String -> Html Msg
fabSpaLink page linkText =
    spaLink Html.button [ Css.flex_1, Css.btn, Css.btn_purple, Css.text_sm ] [ text linkText ] page



-- Archive/Restore Button


archiveButton : Page -> String -> Maybe Bool -> Bool -> Html Msg
archiveButton page url maybeIsArchived canArchive =
    case canArchive of
        -- only show button if user has permission
        False ->
            div [] []

        True ->
            case maybeIsArchived of
                Nothing ->
                    div [ Css.flex_1 ] [ text "..." ]

                Just isArchived ->
                    let
                        clickAction =
                            ActionsPanelMsg <| ArchiveItem (page2loc page) url isArchived
                    in
                    case isArchived of
                        True ->
                            Html.button
                                [ A.type_ "button"
                                , onClick clickAction
                                , A.id "restoreItemButton"
                                , Css.btn
                                , Css.btn_green
                                , Css.text_sm
                                , Css.flex_1
                                ]
                                [ text "Restore" ]

                        False ->
                            Html.button
                                [ A.type_ "button"
                                , onClick clickAction
                                , A.id "archiveItemButton"
                                , Css.btn
                                , Css.btn_red
                                , Css.text_sm
                                , Css.flex_1
                                ]
                                [ text "Remove" ]



-- Links


defaultLinks : List (Html Msg)
defaultLinks =
    [ newKeywordSpa
    , newContactSpa
    , newGroupSpa
    ]


newKeywordSpa : Html Msg
newKeywordSpa =
    fabSpaLink (KeywordForm KF.initialModel Nothing) "New Keyword"


keywords : Html Msg
keywords =
    fabSpaLink (KeywordTable False) "Keywords"


keywordArchive : Html Msg
keywordArchive =
    fabSpaLink (KeywordTable True) "Archived Keywords"


keywordCsv : String -> Html Msg
keywordCsv k =
    fabLink ("/keyword/responses/csv/" ++ k ++ "/") "Export responses"


keywordEdit : String -> Html Msg
keywordEdit k =
    fabSpaLink (KeywordForm KF.initialModel <| Just k) "Edit"


keywordResponsesSpa : Maybe Keyword -> Html Msg
keywordResponsesSpa maybeK =
    case maybeK of
        Nothing ->
            fabLink "#" "..."

        Just k ->
            fabSpaLink (KeyRespTable False False k.keyword) ("Replies (" ++ k.num_replies ++ ")")


keywordArchiveResponsesSpa : Maybe Keyword -> Html Msg
keywordArchiveResponsesSpa k =
    case k of
        Nothing ->
            fabLink "#" "..."

        Just keyword ->
            fabSpaLink (KeyRespTable False True keyword.keyword) ("Archived Replies (" ++ keyword.num_archived_replies ++ ")")


keywordResponses : Maybe Keyword -> Html Msg
keywordResponses maybeK =
    case maybeK of
        Nothing ->
            fabLink "#" "..."

        Just k ->
            fabSpaLink (KeyRespTable False False k.keyword) ("Replies (" ++ k.num_replies ++ ")")


keywordArchiveResponses : Maybe Keyword -> Html Msg
keywordArchiveResponses k =
    case k of
        Nothing ->
            fabLink "#" "..."

        Just keyword ->
            fabSpaLink (KeyRespTable False True keyword.keyword) ("Archived Replies (" ++ keyword.num_archived_replies ++ ")")


newContactSpa : Html Msg
newContactSpa =
    fabSpaLink (ContactForm CF.initialModel Nothing) "New Contact"


contactsSpa : Html Msg
contactsSpa =
    fabSpaLink (RecipientTable False) " Contacts"


contactArchiveSpa : Html Msg
contactArchiveSpa =
    fabSpaLink (RecipientTable True) "Archived Contacts"


groupsArchiveSpa : Html Msg
groupsArchiveSpa =
    fabSpaLink (GroupTable True) "Archived Groups"


groupsSpa : Html Msg
groupsSpa =
    fabSpaLink (GroupTable False) "Groups"


newGroupSpa : Html Msg
newGroupSpa =
    fabSpaLink (GroupForm GF.initialModel Nothing) "New Group"


incomingWall : Html Msg
incomingWall =
    fabSpaLink Wall "Live Updates"


wallCurator : Html Msg
wallCurator =
    fabSpaLink Curator "Live Curator"
