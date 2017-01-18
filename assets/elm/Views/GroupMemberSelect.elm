module Views.GroupMemberSelect exposing (view)

import Views.FilteringTable exposing (filterRecord)
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Messages exposing (..)
import Models exposing (..)
import Regex


-- Main view


view : GroupMemberSelectModel -> Html Msg
view model =
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
                    , cardContainer model.nonmembersFilterRegex model.nonmembers
                    ]
                ]
            , div [ class "ui column" ]
                [ h4 [] [ text "Members" ]
                , div []
                    [ filter (GroupMemberSelectMsg << UpdateMemberFilter)
                    , cardContainer model.membersFilterRegex model.members
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


cardContainer : Regex.Regex -> List RecipientSimple -> Html Msg
cardContainer filterRegex contacts =
    div []
        [ br [] []
        , div [ class "ui three stackable cards" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map card
            )
        ]


card : RecipientSimple -> Html Msg
card contact =
    div [ class "ui raised card" ]
        [ div [ class "content", onClick (GroupMemberSelectMsg (ToggleMembership contact)) ]
            [ text contact.full_name ]
        ]
