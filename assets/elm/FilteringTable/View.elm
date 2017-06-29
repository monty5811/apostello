module FilteringTable.View exposing (filteringTable, uiTable)

import FilteringTable.Messages
    exposing
        ( TableMsg
            ( GoToPage
            , UpdateFilter
            )
        )
import FilteringTable.Model exposing (Model)
import FilteringTable.Util exposing (filterRecord)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import List.Extra as LE
import Messages exposing (Msg(Nope, TableMsg))
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL


emptyView : Html Msg
emptyView =
    Html.div [ A.class "ui message" ] [ Html.text "No data to display" ]


uiTable : Html Msg -> Model -> (a -> Html Msg) -> RL.RemoteList a -> Html Msg
uiTable tableHead tableModel rowConstructor data =
    filteringTable "ui table" tableHead tableModel rowConstructor data


filteringTable : String -> Html Msg -> Model -> (a -> Html Msg) -> RL.RemoteList a -> Html Msg
filteringTable tableClass tableHead model rowConstructor data =
    let
        items =
            RL.toList data

        filteredItems =
            List.filter (filterRecord model.filter) items

        pages =
            paginate filteredItems

        numPages =
            List.length pages

        curPage =
            clampPage numPages model.page
    in
    case List.length items of
        0 ->
            case data of
                RL.NotAsked _ ->
                    loader

                RL.WaitingForFirstResp _ ->
                    loader

                _ ->
                    emptyView

        _ ->
            Html.div []
                [ Html.div [ A.class "ui left icon large transparent fluid input" ]
                    [ Html.i [ A.class "violet filter icon" ] []
                    , Html.input
                        [ A.type_ "text"
                        , A.placeholder "Filter..."
                        , E.onInput (TableMsg << UpdateFilter)
                        ]
                        []
                    ]
                , Html.table [ A.class tableClass ]
                    [ tableHead
                    , Html.tbody [] (getPage curPage pages |> List.map rowConstructor)
                    ]
                , pageControls curPage numPages
                ]


paginate : List a -> List (List a)
paginate rows =
    LE.greedyGroupsOf 100 rows


getPage : Int -> List (List a) -> List a
getPage page rows =
    LE.getAt (page - 1) rows
        |> Maybe.withDefault []


pageControls : Int -> Int -> Html Msg
pageControls page numPages =
    case numPages < 2 of
        True ->
            Html.text ""

        False ->
            Html.div [ A.class "ui stackable pagination small menu" ] <|
                buttons page numPages


buttons : Int -> Int -> List (Html Msg)
buttons curPage numPages =
    let
        middleButtons =
            if curPage == 1 then
                List.concat
                    [ [ pageButton 1 curPage ]
                    , rightButtons curPage numPages
                    , [ pageButton numPages curPage ]
                    ]
            else if curPage == numPages then
                List.concat
                    [ [ pageButton 1 curPage ]
                    , leftButtons curPage
                    , [ pageButton numPages curPage ]
                    ]
            else
                List.concat
                    [ [ pageButton 1 curPage ]
                    , leftButtons curPage
                    , [ pageButton curPage curPage ]
                    , rightButtons curPage numPages
                    , [ pageButton numPages curPage ]
                    ]
    in
    List.concat
        [ [ prevButton curPage ]
        , middleButtons
        , [ nextButton curPage numPages ]
        ]


leftButtons : Int -> List (Html Msg)
leftButtons curPage =
    if curPage == 2 then
        [ Html.text "" ]
    else
        [ Html.div [ A.class "disabled item" ] [ Html.text "..." ]
        , pageButton (curPage - 1) curPage
        ]


rightButtons : Int -> Int -> List (Html Msg)
rightButtons curPage numPages =
    if curPage == numPages - 1 then
        [ Html.text "" ]
    else
        [ pageButton (curPage + 1) curPage
        , Html.div [ A.class "disabled item" ] [ Html.text "..." ]
        ]


prevButton : Int -> Html Msg
prevButton curPage =
    let
        ( class, click ) =
            case curPage == 1 of
                True ->
                    ( "icon disabled item", Nope )

                False ->
                    ( "icon item", TableMsg <| GoToPage <| curPage - 1 )
    in
    Html.a [ A.class class, E.onClick click ] [ Html.i [ A.class "left chevron icon" ] [] ]


nextButton : Int -> Int -> Html Msg
nextButton curPage numPages =
    let
        ( class, click ) =
            case curPage == numPages of
                True ->
                    ( "icon disabled item", Nope )

                False ->
                    ( "icon item", TableMsg <| GoToPage <| curPage + 1 )
    in
    Html.a [ A.class class, E.onClick click ] [ Html.i [ A.class "right chevron icon" ] [] ]


pageButton : Int -> Int -> Html Msg
pageButton goToPage curPage =
    let
        class =
            case curPage == goToPage of
                True ->
                    "active item"

                False ->
                    "item"
    in
    Html.a [ A.class class, E.onClick <| TableMsg <| GoToPage goToPage ] [ Html.text (toString goToPage) ]


clampPage : Int -> Int -> Int
clampPage numPages page =
    clamp 1 numPages page
