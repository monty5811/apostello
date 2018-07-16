module Pages.KeywordTable exposing (view)

import Css
import Data exposing (Keyword)
import FilteringTable as FT
import Helpers exposing (archiveCell)
import Html exposing (Html)
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
    FT.defaultTable { top = props.tableMsg } tableHead props.tableModel (keywordRow props) props.keywords


tableHead : FT.Head
tableHead =
    FT.Head
        [ ""
        , "Matches"
        , "Description"
        , "Auto Reply"
        , "Status"
        , ""
        , ""
        ]


keywordRow : Props msg -> Keyword -> FT.Row msg
keywordRow props keyword =
    FT.Row
        []
        [ FT.Cell [ Css.collapsing ] [ props.keywordRespLink .keyword keyword ]
        , FT.Cell [] [ props.keywordRespLink .num_replies keyword ]
        , FT.Cell [] [ Html.text keyword.description ]
        , FT.Cell [] [ Html.text keyword.current_response ]
        , keywordStatusCell keyword.is_live
        , FT.Cell [ Css.collapsing ] [ props.keywordLink keyword ]
        , FT.Cell [ Css.collapsing ] [ archiveCell keyword.is_archived (props.toggleKeywordArchive keyword.is_archived keyword.keyword) ]
        ]
        (toString keyword.pk)


keywordStatusCell : Bool -> FT.Cell msg
keywordStatusCell isLive =
    case isLive of
        True ->
            FT.Cell [ Css.collapsing ] [ Html.div [ Css.pill, Css.pill_green, Css.text_center ] [ Html.text "Active" ] ]

        False ->
            FT.Cell [ Css.collapsing ] [ Html.div [ Css.pill, Css.pill_orange, Css.text_center ] [ Html.text "Inactive" ] ]
