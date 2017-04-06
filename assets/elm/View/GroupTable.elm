module View.GroupTable exposing (view)

import Html exposing (Html, thead, tr, th, td, text, a)
import Html.Attributes exposing (class, href)
import Messages exposing (Msg(GroupTableMsg), GroupTableMsg(ToggleGroupArchive))
import Models.Apostello exposing (RecipientGroup)
import Regex
import View.Helpers exposing (archiveCell)
import View.FilteringTable exposing (uiTable)
import Round


-- Main view


view : Regex.Regex -> List RecipientGroup -> Html Msg
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
        [ td [] [ a [ href group.url ] [ text group.name ] ]
        , td [] [ text group.description ]
        , td [ class "collapsing" ] [ text ("$" ++ Round.round 2 group.cost) ]
        , archiveCell group.is_archived (GroupTableMsg (ToggleGroupArchive group.is_archived group.pk))
        ]
