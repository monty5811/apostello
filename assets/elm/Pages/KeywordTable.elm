module Pages.KeywordTable exposing (view)

import Data exposing (Keyword)
import FilteringTable as FT
import Helpers exposing (archiveCell)
import Html exposing (Html, a, div, td, text, th, thead, tr)
import Html.Attributes exposing (class)
import Messages exposing (Msg(StoreMsg))
import Pages exposing (Page(KeyRespTable, KeywordForm))
import Pages.Forms.Keyword.Model exposing (initialKeywordFormModel)
import RemoteList as RL
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleKeywordArchive))


-- Main view


view : FT.Model -> RL.RemoteList Keyword -> Html Msg
view tableModel keywords =
    FT.table "table-striped" tableHead tableModel keywordRow keywords


tableHead : Html Msg
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


keywordRow : Keyword -> ( String, Html Msg )
keywordRow keyword =
    ( toString keyword.pk
    , tr []
        [ td [] [ spaLink a [] [ text keyword.keyword ] <| KeyRespTable False keyword.is_archived keyword.keyword ]
        , td [ class "text-center" ] [ spaLink a [] [ text keyword.num_replies ] <| KeyRespTable False keyword.is_archived keyword.keyword ]
        , td [ class "hide-sm-down" ] [ text keyword.description ]
        , td [ class "hide-sm-down" ] [ text keyword.current_response ]
        , keywordStatusCell keyword.is_live
        , td [] [ spaLink a [ class "button" ] [ text "Edit" ] (KeywordForm initialKeywordFormModel <| Just keyword.keyword) ]
        , archiveCell keyword.is_archived (StoreMsg (ToggleKeywordArchive keyword.is_archived keyword.keyword))
        ]
    )


keywordStatusCell : Bool -> Html Msg
keywordStatusCell isLive =
    case isLive of
        True ->
            td [] [ div [ class "badge badge-success" ] [ text "Active" ] ]

        False ->
            td [] [ div [ class "badge badge-warning" ] [ text "Inactive" ] ]
