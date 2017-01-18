module Views.GroupTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Views.Common exposing (archiveCell)
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> GroupTableModel -> Html Msg
view filterRegex model =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "Description" ]
                    , th [] [ text "Cost" ]
                    , th [] []
                    ]
                ]
    in
        filteringTable filterRegex groupRow model.groups head "ui table"


groupRow : RecipientGroup -> Html Msg
groupRow group =
    tr []
        [ td [] [ a [ href group.url ] [ text group.name ] ]
        , td [] [ text group.description ]
        , td [ class "collapsing" ] [ text ("$" ++ group.cost) ]
        , archiveCell group.is_archived (GroupTableMsg (ToggleGroupArchive group.is_archived group.pk))
        ]
