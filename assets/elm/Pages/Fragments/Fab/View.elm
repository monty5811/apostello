module Pages.Fragments.Fab.View exposing (view)

import Data.Keyword exposing (Keyword)
import Data.Store as Store
import Html exposing (..)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (FabModel(..))
import Pages exposing (FabOnlyPage(..), Page(..))
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Pages.GroupForm.Model exposing (initialGroupFormModel)
import Pages.KeywordForm.Model exposing (initialKeywordFormModel)
import Route exposing (page2loc, spaLink)
import Urls as U


view : Store.DataStore -> Page -> FabModel -> Bool -> Html Msg
view ds page model canArchive =
    div []
        [ fabDimView model
        , div [ class "fabContainer" ]
            [ fabDropdownView ds page model canArchive
            , br [] []
            , br [] []
            , fabButtonView
            ]
        ]


fabDropdownView : Store.DataStore -> Page -> FabModel -> Bool -> Html Msg
fabDropdownView ds page model canArchive =
    case model of
        MenuHidden ->
            div [] []

        MenuVisible ->
            div [ class "fabDropdown" ]
                [ div [ class "ui fab large very relaxed inverted list" ]
                    (fabLinks ds page canArchive)
                ]


fabDimView : FabModel -> Html Msg
fabDimView model =
    case model of
        MenuHidden ->
            div [] []

        MenuVisible ->
            div [ class "fabDim", onClick (FabMsg ToggleFabView) ] []


fabButtonView : Html Msg
fabButtonView =
    div [ class "faButton", id "fab", onClick (FabMsg ToggleFabView) ]
        [ div [ class "fabb ui circular violet icon button" ] [ i [ class "large wrench icon" ] [] ]
        ]


fabLinks : Store.DataStore -> Page -> Bool -> List (Html Msg)
fabLinks ds page canArchive =
    case page of
        OutboundTable ->
            defaultLinksSpa

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
            defaultLinksSpa

        Wall ->
            []

        Curator ->
            [ incomingWall ]

        UserProfileTable ->
            [ fabLink "/admin/auth/user/" Table "Admin: Users" ]

        ScheduledSmsTable ->
            defaultLinksSpa

        KeyRespTable _ _ k ->
            let
                keyword =
                    ds.keywords
                        |> Store.toList
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

        AccessDenied ->
            defaultLinksSpa

        SendAdhoc _ ->
            defaultLinksSpa

        SendGroup _ ->
            defaultLinksSpa

        Error404 ->
            defaultLinksSpa

        Home ->
            defaultLinksSpa

        GroupForm _ maybePk ->
            case maybePk of
                Nothing ->
                    defaultLinksSpa

                Just pk ->
                    let
                        isArchived =
                            ds.groups
                                |> Store.toList
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
                    defaultLinksSpa

                Just pk ->
                    let
                        isArchived =
                            ds.recipients
                                |> Store.toList
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
                    defaultLinksSpa

                Just k ->
                    let
                        keyword =
                            ds.keywords
                                |> Store.toList
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
            defaultLinksHref

        FabOnlyPage fabPage ->
            case fabPage of
                Help ->
                    defaultLinksHref

                CreateAllGroup ->
                    [ newGroupHard
                    , groups
                    , groupsArchive
                    ]

                ContactImport ->
                    defaultLinksHref

                ApiSetup ->
                    defaultLinksHref

                EditUserProfile _ ->
                    defaultLinksHref

                EditResponses ->
                    defaultLinksHref


fabLink : String -> Icon -> String -> Html Msg
fabLink uri icon linkText =
    a [ class "hvr-backward item", href uri ]
        [ i [ class ("large " ++ (icon |> iconString) ++ " icon") ] []
        , div [ class "content" ]
            [ div [ class "header" ] [ text linkText ]
            ]
        ]


fabSpaLink : Page -> Icon -> String -> Html Msg
fabSpaLink page icon linkText =
    spaLink a
        [ class "hvr-backward item" ]
        [ i [ class ("large " ++ (icon |> iconString) ++ " icon") ] []
        , div [ class "content" ]
            [ div [ class "header" ] [ text linkText ]
            ]
        ]
        page



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
                    div [ class "ui fluid grey button" ] [ text "Loading..." ]

                Just isArchived ->
                    let
                        clickAction =
                            FabMsg <| ArchiveItem (page2loc page) url isArchived
                    in
                    case isArchived of
                        True ->
                            div
                                [ class "ui fluid positive button"
                                , onClick clickAction
                                ]
                                [ text "Restore" ]

                        False ->
                            div
                                [ class "ui fluid negative button"
                                , onClick clickAction
                                ]
                                [ text "Remove" ]



-- Links


type Icon
    = Table
    | Inbox
    | Plus
    | Download
    | Edit


iconString : Icon -> String
iconString icon =
    case icon of
        Table ->
            "table"

        Inbox ->
            "inbox"

        Plus ->
            "plus"

        Download ->
            "download"

        Edit ->
            "edit"


defaultLinksHref : List (Html Msg)
defaultLinksHref =
    [ newKeywordHard
    , newContactHard
    , newGroupHard
    ]


defaultLinksSpa : List (Html Msg)
defaultLinksSpa =
    [ newKeywordSpa
    , newContactSpa
    , newGroupSpa
    ]


newKeywordHard : Html Msg
newKeywordHard =
    fabLink (page2loc <| KeywordForm initialKeywordFormModel Nothing) Plus "New Keyword"


newKeywordSpa : Html Msg
newKeywordSpa =
    fabSpaLink (KeywordForm initialKeywordFormModel Nothing) Plus "New Keyword"


keywords : Html Msg
keywords =
    fabSpaLink (KeywordTable False) Table " Keywords"


keywordArchive : Html Msg
keywordArchive =
    fabSpaLink (KeywordTable True) Table "Archived Keywords"


keywordCsv : String -> Html Msg
keywordCsv k =
    fabLink ("/keyword/responses/csv/" ++ k ++ "/") Download "Export responses"


keywordEdit : String -> Html Msg
keywordEdit k =
    fabSpaLink (KeywordForm initialKeywordFormModel <| Just k) Edit "Edit"


keywordResponsesSpa : Maybe Keyword -> Html Msg
keywordResponsesSpa maybeK =
    case maybeK of
        Nothing ->
            fabLink "#" Inbox "..."

        Just k ->
            fabSpaLink (KeyRespTable False False k.keyword) Inbox ("Replies (" ++ k.num_replies ++ ")")


keywordArchiveResponsesSpa : Maybe Keyword -> Html Msg
keywordArchiveResponsesSpa k =
    case k of
        Nothing ->
            fabLink "#" Inbox "..."

        Just keyword ->
            fabSpaLink (KeyRespTable False True keyword.keyword) Inbox ("Archived Replies (" ++ keyword.num_archived_replies ++ ")")


keywordResponses : Maybe Keyword -> Html Msg
keywordResponses maybeK =
    case maybeK of
        Nothing ->
            fabLink "#" Inbox "..."

        Just k ->
            fabLink (page2loc <| KeyRespTable False False k.keyword) Inbox ("Replies (" ++ k.num_replies ++ ")")


keywordArchiveResponses : Maybe Keyword -> Html Msg
keywordArchiveResponses k =
    case k of
        Nothing ->
            fabLink "#" Inbox "..."

        Just keyword ->
            fabLink (page2loc <| KeyRespTable False True keyword.keyword) Inbox ("Archived Replies (" ++ keyword.num_archived_replies ++ ")")


newContactHard : Html Msg
newContactHard =
    fabLink (page2loc <| ContactForm initialContactFormModel Nothing) Plus "New Contact"


newContactSpa : Html Msg
newContactSpa =
    fabSpaLink (ContactForm initialContactFormModel Nothing) Plus "New Contact"


contactsSpa : Html Msg
contactsSpa =
    fabSpaLink (RecipientTable False) Table " Contacts"


contactArchiveSpa : Html Msg
contactArchiveSpa =
    fabSpaLink (RecipientTable True) Table "Archived Contacts"


groupsArchiveSpa : Html Msg
groupsArchiveSpa =
    fabSpaLink (GroupTable True) Table "Archived Groups"


groupsArchive : Html Msg
groupsArchive =
    fabLink (page2loc <| GroupTable True) Table "Archived Groups"


groupsSpa : Html Msg
groupsSpa =
    fabSpaLink (GroupTable False) Table "Groups"


groups : Html Msg
groups =
    fabLink (page2loc <| GroupTable False) Table "Groups"


newGroupHard : Html Msg
newGroupHard =
    fabLink (page2loc <| GroupForm initialGroupFormModel Nothing) Plus "New Group"


newGroupSpa : Html Msg
newGroupSpa =
    fabSpaLink (GroupForm initialGroupFormModel Nothing) Plus "New Group"


incomingWall : Html Msg
incomingWall =
    fabSpaLink Wall Inbox "Live Updates"


wallCurator : Html Msg
wallCurator =
    fabSpaLink Curator Table "Live Curator"
