module Views.Fab exposing (view)

import Models exposing (..)
import Messages exposing (..)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, id, href)


view : FabModel -> Html Msg
view model =
    div []
        [ fabDimView model.fabState
        , div [ class "fabContainer" ]
            [ fabDropdownView model
            , br [] []
            , br [] []
            , fabButtonView
            ]
        ]


fabDropdownView : FabModel -> Html Msg
fabDropdownView model =
    case model.fabState of
        MenuHidden ->
            div [] []

        MenuVisible ->
            div [ class "fabDropdown" ]
                [ div [ class "ui fab large very relaxed inverted list" ]
                    ((archiveButton model.archiveButton) :: (linksList model.pageLinks))
                ]


fabDimView : FabState -> Html Msg
fabDimView state =
    case state of
        MenuHidden ->
            div [] []

        MenuVisible ->
            div [ class "fabDim", onClick (FabMsg ToggleFabView) ] []


fabButtonView : Html Msg
fabButtonView =
    div [ class "faButton", id "fab", onClick (FabMsg ToggleFabView) ]
        [ div [ class "fabb ui circular violet icon button" ] [ i [ class "large wrench icon" ] [] ]
        ]


linksList : List PageLink -> List (Html Msg)
linksList links =
    List.map fabLink links


fabLink : PageLink -> Html Msg
fabLink pageLink =
    a [ class "hvr-backward item", href pageLink.url ]
        [ i [ class ("large " ++ pageLink.iconType ++ " icon") ] []
        , div [ class "content" ]
            [ div [ class "header" ] [ text pageLink.linkText ]
            ]
        ]


archiveButton : Maybe ArchiveButton -> Html Msg
archiveButton r =
    case r of
        Just ab ->
            case ab.isArchived of
                True ->
                    div [ class "ui fluid positive button", onClick (FabMsg ArchiveItem) ] [ text "Restore" ]

                False ->
                    div [ class "ui fluid negative button", onClick (FabMsg ArchiveItem) ] [ text "Remove" ]

        Nothing ->
            div [] []
