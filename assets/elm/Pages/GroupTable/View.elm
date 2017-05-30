module Pages.GroupTable.View exposing (view)

import Data.RecipientGroup exposing (RecipientGroup)
import Data.Store as Store
import FilteringTable exposing (uiTable)
import Helpers exposing (archiveCell)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Messages exposing (Msg(GroupTableMsg))
import Pages exposing (Page(GroupForm))
import Pages.GroupForm.Model exposing (initialGroupFormModel)
import Pages.GroupTable.Messages exposing (GroupTableMsg(ToggleGroupArchive))
import Regex
import Round
import Route exposing (spaLink)


-- Main view


view : Regex.Regex -> Store.RemoteList RecipientGroup -> Html Msg
view filterRegex groups =
    uiTable tableHead filterRegex groupRow groups


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
        , archiveCell group.is_archived (GroupTableMsg (ToggleGroupArchive group.is_archived group.pk))
        ]
