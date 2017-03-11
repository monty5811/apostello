module View.GroupMemberSelect exposing (view)

import View.FilteringTable exposing (filterRecord)
import Html exposing (..)
import Html.Attributes exposing (class, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Models.Apostello exposing (RecipientGroup, RecipientSimple)
import Models.GroupMemberSelect exposing (GroupMemberSelectModel)
import Regex


-- Main view


view : Maybe RecipientGroup -> GroupMemberSelectModel -> Html Msg
view maybeGroup model =
    case maybeGroup of
        Nothing ->
            div [] []

        Just group ->
            div []
                [ h3 []
                    [ text "Group Members" ]
                , p []
                    [ text "Click a person to toggle their membership." ]
                , div [ class "ui two column celled grid" ]
                    [ div [ class "ui column" ]
                        [ h4 [] [ text "Non-Members" ]
                        , div []
                            [ filter (GroupMemberSelectMsg << UpdateNonMemberFilter)
                            , cardContainer model.nonmembersFilterRegex group.nonmembers group
                            ]
                        ]
                    , div [ class "ui column" ]
                        [ h4 [] [ text "Members" ]
                        , div []
                            [ filter (GroupMemberSelectMsg << UpdateMemberFilter)
                            , cardContainer model.membersFilterRegex group.members group
                            ]
                        ]
                    ]
                ]


filter : (String -> Msg) -> Html Msg
filter handleInput =
    div [ class "ui left icon large transparent fluid input" ]
        [ input [ placeholder "Filter...", type_ "text", onInput handleInput ] []
        , i [ class "violet filter icon" ] []
        ]


cardContainer : Regex.Regex -> List RecipientSimple -> RecipientGroup -> Html Msg
cardContainer filterRegex contacts group =
    div []
        [ br [] []
        , div [ class "ui three stackable cards" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map (card group)
            )
        ]


card : RecipientGroup -> RecipientSimple -> Html Msg
card group contact =
    div [ class "ui raised card" ]
        [ div [ class "content", onClick (GroupMemberSelectMsg (ToggleMembership group contact)) ]
            [ text contact.full_name ]
        ]
