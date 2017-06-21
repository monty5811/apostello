module Pages.ElvantoImport.View exposing (view)

import Data.ElvantoGroup exposing (ElvantoGroup)
import FilteringTable.Model as FTM
import FilteringTable.View exposing (filteringTable)
import Helpers exposing (formatDate)
import Html exposing (Html, a, br, div, td, text, th, thead, tr)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Messages exposing (Msg)
import Pages.ElvantoImport.Messages exposing (ElvantoMsg(..))
import Store.Messages exposing (StoreMsg(ToggleElvantoGroupSync))
import RemoteList as RL


-- Main view


view : FTM.Model -> RL.RemoteList ElvantoGroup -> Html Msg
view tableModel groups =
    div []
        [ div [ class "ui fluid buttons" ] [ fetchButton, pullButton ]
        , br [] []
        , filteringTable "ui striped compact definition table" tableHead tableModel groupRow groups
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
    a [ class "ui green button", onClick (Messages.ElvantoMsg FetchGroups), id "fetch_button" ] [ text "Fetch Groups" ]


pullButton : Html Msg
pullButton =
    a [ class "ui blue button", onClick (Messages.ElvantoMsg PullGroups), id "pull_button" ] [ text "Pull Groups" ]


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
    button_ "ui tiny green button" "Syncing" group


notSyncingButton : ElvantoGroup -> Html Msg
notSyncingButton group =
    button_ "ui tiny grey button" "Disabled" group


button_ : String -> String -> ElvantoGroup -> Html Msg
button_ styling label group =
    a [ class styling, onClick (Messages.StoreMsg (ToggleElvantoGroupSync group)) ] [ text label ]
