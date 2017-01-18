module Views.ElvantoImport exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> ElvantoImportModel -> Html Msg
view filterRegex model =
    let
        head =
            thead []
                [ tr []
                    [ th [] []
                    , th [] [ text "Last Synced" ]
                    , th [] [ text "Sync?" ]
                    ]
                ]
    in
        div []
            [ div [ class "ui fluid buttons" ]
                [ fetchButton
                , pullButton
                ]
            , br [] []
            , filteringTable filterRegex groupRow model.groups head "ui striped compact definition table"
            ]


fetchButton : Html Msg
fetchButton =
    a [ class "ui green button", onClick (ElvantoMsg FetchGroups), id "fetch_button" ] [ text "Fetch Groups" ]


pullButton : Html Msg
pullButton =
    a [ class "ui blue button", onClick (ElvantoMsg PullGroups), id "pull_button" ] [ text "Pull Groups" ]


groupRow : ElvantoGroup -> Html Msg
groupRow group =
    tr []
        [ td [] [ text group.name ]
        , td [] [ text group.last_synced ]
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
    a [ class styling, onClick (ElvantoMsg (ToggleGroupSync group)) ] [ text label ]
