module Views.KeywordTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Views.Common exposing (archiveCell)
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> KeywordTableModel -> Html Msg
view filterRegex model =
    let
        head =
            thead []
                [ tr []
                    [ th [] []
                    , th [] [ text "Matches" ]
                    , th [] [ text "Description" ]
                    , th [] [ text "Auto Reply" ]
                    , th [] [ text "Status" ]
                    , th [] []
                    , th [] []
                    ]
                ]
    in
        filteringTable filterRegex keywordRow model.keywords head "ui striped definition table"


keywordRow : Keyword -> Html Msg
keywordRow keyword =
    tr []
        [ td [] [ a [ href keyword.responses_url ] [ text keyword.keyword ] ]
        , td [ class "center aligned" ] [ a [ href keyword.responses_url ] [ text keyword.num_replies ] ]
        , td [] [ text keyword.description ]
        , td [] [ text keyword.current_response ]
        , keywordStatusCell keyword.is_live
        , td [] [ a [ href keyword.url, class "ui tiny primary button" ] [ text "Edit" ] ]
        , archiveCell keyword.is_archived (KeywordTableMsg (ToggleKeywordArchive keyword.is_archived keyword.pk))
        ]


keywordStatusCell : Bool -> Html Msg
keywordStatusCell isLive =
    case isLive of
        True ->
            td [] [ div [ class "ui green label" ] [ text "Active" ] ]

        False ->
            td [] [ div [ class "ui orange label" ] [ text "Inactive" ] ]
