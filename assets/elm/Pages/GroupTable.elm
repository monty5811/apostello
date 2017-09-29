module Pages.GroupTable exposing (view)

import Data exposing (RecipientGroup)
import FilteringTable as FT
import Helpers exposing (archiveCell)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes as A
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(GroupForm))
import Pages.Forms.Group.Model exposing (initialGroupFormModel)
import RemoteList as RL
import Round
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleGroupArchive))


-- Main view


view : FT.Model -> RL.RemoteList RecipientGroup -> Html Msg
view tableModel groups =
    FT.defaultTable tableHead tableModel groupRow groups


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "Name" ]
            , th [ A.class "hide-sm-down" ] [ text "Description" ]
            , th [] [ text "Cost" ]
            , th [ A.class "hide-sm-down" ] []
            ]
        ]


groupRow : RecipientGroup -> ( String, Html Msg )
groupRow group =
    ( toString group.pk
    , tr []
        [ td [] [ spaLink a [] [ text group.name ] <| GroupForm initialGroupFormModel <| Just group.pk ]
        , td [ A.class "hide-sm-down" ] [ text group.description ]
        , td [] [ text ("$" ++ Round.round 2 group.cost) ]
        , archiveCell group.is_archived (StoreMsg (ToggleGroupArchive group.is_archived group.pk))
        ]
    )
