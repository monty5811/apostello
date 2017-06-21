module Pages.GroupTable exposing (view)

import Data.RecipientGroup exposing (RecipientGroup)
import FilteringTable.Model as FTM
import FilteringTable.View exposing (uiTable)
import Helpers exposing (archiveCell)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(GroupForm))
import Pages.Forms.Group.Model exposing (initialGroupFormModel)
import Round
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleGroupArchive))
import RemoteList as RL


-- Main view


view : FTM.Model -> RL.RemoteList RecipientGroup -> Html Msg
view tableModel groups =
    uiTable tableHead tableModel groupRow groups


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "Name" ]
            , th [] [ text "Description" ]
            , th [] [ text "Cost" ]
            , th [] []
            ]
        ]


groupRow : RecipientGroup -> Html Msg
groupRow group =
    tr []
        [ td [] [ spaLink a [] [ text group.name ] <| GroupForm initialGroupFormModel <| Just group.pk ]
        , td [] [ text group.description ]
        , td [ class "collapsing" ] [ text ("$" ++ Round.round 2 group.cost) ]
        , archiveCell group.is_archived (StoreMsg (ToggleGroupArchive group.is_archived group.pk))
        ]
