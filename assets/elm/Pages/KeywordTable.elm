module Pages.KeywordTable exposing (view)

import Data exposing (Keyword)
import FilteringTable as FT
import Helpers exposing (archiveCell)
import Html exposing (Html, div, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import RemoteList as RL


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , tableModel : FT.Model
    , keywords : RL.RemoteList Keyword
    , keywordLink : Keyword -> Html msg
    , keywordRespLink : (Keyword -> String) -> Keyword -> Html msg
    , toggleKeywordArchive : Bool -> String -> msg
    }


view : Props msg -> Html msg
view props =
    FT.table { top = props.tableMsg } "table-striped" tableHead props.tableModel (keywordRow props) props.keywords


tableHead : Html msg
tableHead =
    thead []
        [ tr []
            [ th [] []
            , th [] [ text "Matches" ]
            , th [ class "hide-sm-down" ] [ text "Description" ]
            , th [ class "hide-sm-down" ] [ text "Auto Reply" ]
            , th [] [ text "Status" ]
            , th [] []
            , th [ class "hide-sm-down" ] []
            ]
        ]


keywordRow : Props msg -> Keyword -> ( String, Html msg )
keywordRow props keyword =
    ( toString keyword.pk
    , tr []
        [ td [] [ props.keywordRespLink .keyword keyword ]
        , td [ class "text-center" ] [ props.keywordRespLink .num_replies keyword ]
        , td [ class "hide-sm-down" ] [ text keyword.description ]
        , td [ class "hide-sm-down" ] [ text keyword.current_response ]
        , keywordStatusCell keyword.is_live
        , td [] [ props.keywordLink keyword ]
        , archiveCell keyword.is_archived (props.toggleKeywordArchive keyword.is_archived keyword.keyword)
        ]
    )


keywordStatusCell : Bool -> Html msg
keywordStatusCell isLive =
    case isLive of
        True ->
            td [] [ div [ class "badge badge-success" ] [ text "Active" ] ]

        False ->
            td [] [ div [ class "badge badge-warning" ] [ text "Inactive" ] ]
