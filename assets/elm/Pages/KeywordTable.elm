module Pages.KeywordTable exposing (view)

import Data.Keyword exposing (Keyword)
import FilteringTable.Model as FTM
import FilteringTable.View exposing (filteringTable)
import Helpers exposing (archiveCell)
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(KeyRespTable, KeywordForm))
import Pages.Forms.Keyword.Model exposing (initialKeywordFormModel)
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleKeywordArchive))
import RemoteList as RL


-- Main view


view : FTM.Model -> RL.RemoteList Keyword -> Html Msg
view tableModel keywords =
    filteringTable "ui striped definition table" tableHead tableModel keywordRow keywords


tableHead : Html Msg
tableHead =
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


keywordRow : Keyword -> Html Msg
keywordRow keyword =
    tr []
        [ td [] [ spaLink a [] [ text keyword.keyword ] <| KeyRespTable False keyword.is_archived keyword.keyword ]
        , td [ class "center aligned" ] [ spaLink a [] [ text keyword.num_replies ] <| KeyRespTable False keyword.is_archived keyword.keyword ]
        , td [] [ text keyword.description ]
        , td [] [ text keyword.current_response ]
        , keywordStatusCell keyword.is_live
        , td [] [ spaLink a [ class "ui tiny primary button" ] [ text "Edit" ] (KeywordForm initialKeywordFormModel <| Just keyword.keyword) ]
        , archiveCell keyword.is_archived (StoreMsg (ToggleKeywordArchive keyword.is_archived keyword.keyword))
        ]


keywordStatusCell : Bool -> Html Msg
keywordStatusCell isLive =
    case isLive of
        True ->
            td [] [ div [ class "ui green label" ] [ text "Active" ] ]

        False ->
            td [] [ div [ class "ui orange label" ] [ text "Inactive" ] ]
