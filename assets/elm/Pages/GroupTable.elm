module Pages.GroupTable exposing (view)

import Data exposing (RecipientGroup)
import FilteringTable as FT
import Helpers exposing (archiveCell)
import Html exposing (Html, td, text, th, thead, tr)
import Html.Attributes as A
import RemoteList as RL
import Round


-- Main view


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , tableModel : FT.Model
    , groups : RL.RemoteList RecipientGroup
    , toggleArchiveGroup : Bool -> Int -> msg
    , groupFormLink : RecipientGroup -> Html msg
    }


view : Props msg -> Html msg
view props =
    FT.defaultTable { top = props.tableMsg } tableHead props.tableModel (groupRow props) props.groups


tableHead : Html msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "Name" ]
            , th [ A.class "hide-sm-down" ] [ text "Description" ]
            , th [] [ text "Cost" ]
            , th [ A.class "hide-sm-down" ] []
            ]
        ]


groupRow : Props msg -> RecipientGroup -> ( String, Html msg )
groupRow props group =
    ( toString group.pk
    , tr []
        [ td [] [ props.groupFormLink group ]
        , td [ A.class "hide-sm-down" ] [ text group.description ]
        , td [] [ text ("$" ++ Round.round 2 group.cost) ]
        , archiveCell group.is_archived (props.toggleArchiveGroup group.is_archived group.pk)
        ]
    )
