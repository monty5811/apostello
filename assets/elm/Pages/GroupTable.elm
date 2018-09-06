module Pages.GroupTable exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (RecipientGroup)
import FilteringTable as FT
import Helpers exposing (archiveCell)
import Html exposing (Html)
import RemoteList as RL
import Round


-- Model


type alias Model =
    { tableModel : FT.Model
    }


initialModel : Model
initialModel =
    { tableModel = FT.initialModel }



-- Update


type Msg
    = TableMsg FT.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        TableMsg tableMsg ->
            { model | tableModel = FT.update tableMsg model.tableModel }



-- Main view


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , groups : RL.RemoteList RecipientGroup
    , toggleArchiveGroup : Bool -> Int -> msg
    , groupFormLink : RecipientGroup -> Html msg
    }


view : Props msg -> Model -> Html msg
view props { tableModel } =
    FT.defaultTable { top = props.tableMsg } tableHead tableModel (groupRow props) props.groups


tableHead : FT.Head
tableHead =
    FT.Head
        [ "Name"
        , "Description"
        , "Cost"
        , ""
        ]


groupRow : Props msg -> RecipientGroup -> FT.Row msg
groupRow props group =
    FT.Row []
        [ FT.Cell [] [ props.groupFormLink group ]
        , FT.Cell [] [ Html.text group.description ]
        , FT.Cell [ Css.collapsing ] [ Html.text ("$" ++ Round.round 2 group.cost) ]
        , FT.Cell [ Css.collapsing ] [ archiveCell group.is_archived (props.toggleArchiveGroup group.is_archived group.pk) ]
        ]
        (toString group.pk)
