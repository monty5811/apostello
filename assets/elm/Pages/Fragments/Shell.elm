module Pages.Fragments.Shell exposing (view)

import Css
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(NotificationMsg, ScrollToId))
import Models exposing (Model)
import Notification as Notif
import Pages exposing (Page(..))
import Pages.Fragments.Menu as Menu
import Route exposing (spaLink)


view : Model -> Html Msg -> List (Html Msg) -> Html Msg
view model mainContent actionsList =
    case model.page of
        Wall ->
            mainContent

        Usage ->
            mainContent

        FirstRun _ ->
            mainContent

        _ ->
            commonShell model mainContent actionsList


commonShell : Model -> Html Msg -> List (Html Msg) -> Html Msg
commonShell model mainContent actionsList =
    let
        bigHeading =
            case model.page of
                Home ->
                    apostelloHeading

                _ ->
                    spaLink Html.a [] [ apostelloHeading ] Home
    in
    Html.div
        [ A.id "elmShell"
        ]
        [ Html.header [ A.id "head" ]
            [ bigHeading
            , Html.h3 [ Css.mt_2, Css.mb_4, Css.text_center ] [ Html.text <| title model.page ]
            , scrollToMenuButton
            ]
        , Html.aside [ A.id "actionsWrapper", Css.raisedSegment ] actionsList
        , Html.main_ [ A.id "wrap", Css.raisedSegment, Css.py_4, A.class "overflow-x-auto" ]
            [ Html.div [ A.id "content" ] <|
                List.concat
                    [ List.map (Html.map NotificationMsg) (Notif.view model.notifications)
                    , [ mainContent ]
                    ]
            ]
        , Html.aside [ A.id "menuWrapper", Css.raisedSegment, Css.pb_4 ] <| Menu.menu model.settings model.webPush
        ]


scrollToMenuButton : Html Msg
scrollToMenuButton =
    Html.div
        [ E.onClick <| ScrollToId "menuWrapper"
        , Css.text_sm
        , Css.select_none
        , Css.cursor_pointer
        , Css.lg__hidden
        , Css.btn
        , Css.btn_purple
        , Css.pin_r
        , Css.pin_t
        , Css.absolute
        , Css.mt_4
        , Css.mr_4
        ]
        [ Html.text "Menu " ]


apostelloHeading : Html msg
apostelloHeading =
    Html.h2 [ Css.text_center ] [ Html.text "apostello" ]


title : Page -> String
title page =
    case page of
        Home ->
            ""

        AccessDenied ->
            ""

        Debug _ ->
            "Debug Configuration"

        ContactForm _ (Just _) ->
            "Edit Contact"

        ContactForm _ Nothing ->
            "New Contact"

        CreateAllGroup _ ->
            ""

        Curator ->
            "Wall Curator"

        ElvantoImport ->
            "Elvanto Sync"

        Error404 ->
            ""

        FirstRun _ ->
            ""

        GroupComposer _ ->
            ""

        GroupForm _ (Just _) ->
            "Edit Group"

        GroupForm _ Nothing ->
            "New Group"

        GroupTable True ->
            "Groups (archived)"

        GroupTable False ->
            "Groups"

        InboundTable ->
            "Incoming"

        KeyRespTable _ True k ->
            k ++ " reponses (archived)"

        KeyRespTable _ False k ->
            k ++ " reponses"

        KeywordForm _ (Just _) ->
            "Edit Keyword"

        KeywordForm _ Nothing ->
            "New Keyword"

        KeywordTable False ->
            "Keywords"

        KeywordTable True ->
            "Keywords (archived)"

        OutboundTable ->
            "Outgoing"

        RecipientTable False ->
            "Contacts"

        RecipientTable True ->
            "Contacts (archived)"

        ScheduledSmsTable ->
            "Scheduled"

        SendAdhoc _ ->
            "Send to individuals"

        SendGroup _ ->
            "Send to a group"

        UserProfileTable ->
            "Permissions"

        Wall ->
            ""

        SiteConfigForm _ ->
            "Configuration"

        DefaultResponsesForm _ ->
            "Default Responses"

        Usage ->
            ""

        UserProfileForm _ _ ->
            ""

        Help ->
            "Help"

        ContactImport _ ->
            "CSV Import"

        ApiSetup _ ->
            "API Setup"
