module Views.Fab exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, id, href)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Route exposing (page2loc)
import Urls
import Views.Helpers exposing (spaLink)


view : DataStore -> Page -> FabModel -> Html Msg
view ds page model =
    div []
        [ fabDimView model
        , div [ class "fabContainer" ]
            [ fabDropdownView ds page model
            , br [] []
            , br [] []
            , fabButtonView
            ]
        ]


fabDropdownView : DataStore -> Page -> FabModel -> Html Msg
fabDropdownView ds page model =
    case model of
        MenuHidden ->
            div [] []

        MenuVisible ->
            div [ class "fabDropdown" ]
                [ div [ class "ui fab large very relaxed inverted list" ]
                    (fabLinks ds page)
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


fabLinks : DataStore -> Page -> List (Html Msg)
fabLinks ds page =
    case page of
        OutboundTable ->
            defaultLinksHref

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
                [ newGroup, otherLink ]

        GroupComposer ->
            [ newGroup, groupsSpa, groupsArchiveSpa ]

        RecipientTable viewingArchive ->
            let
                otherLink =
                    case viewingArchive of
                        True ->
                            contactsSpa

                        False ->
                            contactArchiveSpa
            in
                [ newContact, otherLink ]

        KeywordTable viewingArchive ->
            let
                otherLink =
                    case viewingArchive of
                        True ->
                            keywords

                        False ->
                            keywordArchive
            in
                [ newKeyword, otherLink ]

        ElvantoImport ->
            defaultLinksHref

        Wall ->
            []

        Curator ->
            [ incomingWall ]

        UserProfileTable ->
            [ fabLink "/admin/auth/user/" Table "Admin: Users" ]

        ScheduledSmsTable ->
            defaultLinksHref

        KeyRespTable viewingArchive k ->
            let
                keyword =
                    List.filter (\x -> x.keyword == k) ds.keywords
                        |> List.head
            in
                [ keywordEdit k
                , keywordCsv k
                , keywordResponsesSpa keyword
                , keywordArchiveResponsesSpa keyword
                ]

        FirstRun ->
            []

        AccessDenied ->
            defaultLinksHref

        SendAdhoc _ _ ->
            defaultLinksHref

        SendGroup _ _ ->
            defaultLinksHref

        Error404 ->
            defaultLinksHref

        Home ->
            defaultLinksHref

        EditGroup pk ->
            let
                isArchived =
                    ds.groups
                        |> List.filter (\x -> x.pk == pk)
                        |> List.head
                        |> Maybe.map .is_archived
            in
                [ archiveButton (GroupTable False) (Urls.group pk) isArchived ]

        EditContact pk ->
            let
                isArchived =
                    List.filter (\x -> x.pk == pk) ds.recipients
                        |> List.head
                        |> Maybe.map .is_archived
            in
                [ archiveButton (RecipientTable False) (Urls.recipient pk) isArchived ]

        FabOnlyPage fabPage ->
            case fabPage of
                Help ->
                    defaultLinksHref

                NewGroup ->
                    defaultLinksHref

                CreateAllGroup ->
                    [ newGroup
                    , groups
                    , groupsArchive
                    ]

                NewContact ->
                    defaultLinksHref

                NewKeyword ->
                    defaultLinksHref

                EditKeyword k ->
                    let
                        keyword =
                            List.filter (\x -> x.keyword == k) ds.keywords
                                |> List.head

                        isArchived =
                            keyword
                                |> Maybe.map .is_archived
                    in
                        [ keywordResponses keyword
                        , keywordArchiveResponses keyword
                        , archiveButton (KeywordTable False) (Urls.keyword k) isArchived
                        ]

                ContactImport ->
                    defaultLinksHref

                ApiSetup ->
                    defaultLinksHref

                EditUserProfile _ ->
                    defaultLinksHref

                EditSiteConfig ->
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


archiveButton : Page -> String -> Maybe Bool -> Html Msg
archiveButton page url maybeIsArchived =
    case maybeIsArchived of
        Nothing ->
            div [ class "ui fluid grey button" ] [ text "Loading..." ]

        Just isArchived ->
            case isArchived of
                True ->
                    div [ class "ui fluid positive button", onClick <| FabMsg <| ArchiveItem (page2loc <| page) url isArchived ] [ text "Restore" ]

                False ->
                    div [ class "ui fluid negative button", onClick <| FabMsg <| ArchiveItem (page2loc <| page) url isArchived ] [ text "Remove" ]



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
    [ newKeyword
    , newContact
    , newGroup
    ]


newKeyword : Html Msg
newKeyword =
    fabLink (page2loc (FabOnlyPage NewKeyword)) Plus "New Keyword"


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
    fabLink (page2loc <| FabOnlyPage <| EditKeyword k) Edit "Edit"


keywordResponsesSpa : Maybe Keyword -> Html Msg
keywordResponsesSpa maybeK =
    case maybeK of
        Nothing ->
            fabLink "#" Inbox "..."

        Just k ->
            fabSpaLink (KeyRespTable False k.keyword) Inbox ("Replies (" ++ k.num_replies ++ ")")


keywordArchiveResponsesSpa : Maybe Keyword -> Html Msg
keywordArchiveResponsesSpa k =
    case k of
        Nothing ->
            fabLink "#" Inbox "..."

        Just keyword ->
            fabSpaLink (KeyRespTable True keyword.keyword) Inbox ("Archived Replies (" ++ keyword.num_archived_replies ++ ")")


keywordResponses : Maybe Keyword -> Html Msg
keywordResponses maybeK =
    case maybeK of
        Nothing ->
            fabLink "#" Inbox "..."

        Just k ->
            fabLink (page2loc <| KeyRespTable False k.keyword) Inbox ("Replies (" ++ k.num_replies ++ ")")


keywordArchiveResponses : Maybe Keyword -> Html Msg
keywordArchiveResponses k =
    case k of
        Nothing ->
            fabLink "#" Inbox "..."

        Just keyword ->
            fabLink (page2loc <| KeyRespTable True keyword.keyword) Inbox ("Archived Replies (" ++ keyword.num_archived_replies ++ ")")


newContact : Html Msg
newContact =
    fabLink (page2loc <| FabOnlyPage <| NewContact) Plus "New Contact"


contacts : Html Msg
contacts =
    fabLink (page2loc <| RecipientTable False) Table " Contacts"


contactArchive : Html Msg
contactArchive =
    fabLink (page2loc <| RecipientTable True) Table "Archived Contacts"


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


newGroup : Html Msg
newGroup =
    fabLink (page2loc <| FabOnlyPage NewGroup) Plus "New Group"


incomingWall : Html Msg
incomingWall =
    fabSpaLink Wall Inbox "Live Updates"


wallCurator : Html Msg
wallCurator =
    fabSpaLink Curator Table "Live Curator"
