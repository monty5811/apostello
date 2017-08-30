module Pages.ElvantoImport.View exposing (view)

import Data exposing (ElvantoGroup)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html, a, br, div, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Messages exposing (Msg)
import Pages.ElvantoImport.Messages exposing (ElvantoMsg(..))
import RemoteList as RL
import Rocket exposing ((=>))
import Store.Messages exposing (StoreMsg(ToggleElvantoGroupSync))


-- Main view


view : FT.Model -> RL.RemoteList ElvantoGroup -> Html Msg
view tableModel groups =
    div []
        [ div [] [ fetchButton, pullButton ]
        , br [] []
        , FT.filteringTable "table-striped" tableHead tableModel groupRow groups
        ]


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] []
            , th [] [ text "Last Synced" ]
            , th [] [ text "Sync?" ]
            ]
        ]


fetchButton : Html Msg
fetchButton =
    a
        [ A.class "button button-success"
        , onClick (Messages.ElvantoMsg FetchGroups)
        , A.id "fetch_button"
        , A.style [ "width" => "50%" ]
        ]
        [ text "Fetch Groups" ]


pullButton : Html Msg
pullButton =
    a
        [ A.class "button button-info"
        , onClick (Messages.ElvantoMsg PullGroups)
        , A.id "pull_button"
        , A.style [ "width" => "50%" ]
        ]
        [ text "Pull Groups" ]


groupRow : ElvantoGroup -> Html Msg
groupRow group =
    tr []
        [ td [] [ text group.name ]
        , td [] [ text (formatDate group.last_synced) ]
        , td [] [ toggleSyncButton group ]
        ]


toggleSyncButton : ElvantoGroup -> Html Msg
toggleSyncButton group =
    case group.sync of
        True ->
            syncingButton group

        False ->
            notSyncingButton group


syncingButton : ElvantoGroup -> Html Msg
syncingButton group =
    button_ "button button-success" "Syncing" group


notSyncingButton : ElvantoGroup -> Html Msg
notSyncingButton group =
    button_ "button button-secondary" "Disabled" group


button_ : String -> String -> ElvantoGroup -> Html Msg
button_ styling label group =
    a
        [ A.class styling
        , A.id "elvantoGroupButton"
        , onClick (Messages.StoreMsg (ToggleElvantoGroupSync group))
        ]
        [ text label ]
