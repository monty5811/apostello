module FilteringTable
    exposing
        ( Model
        , defaultTable
        , filterInput
        , filterRecord
        , initialModel
        , table
        , textToRegex
        , update
        )

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import List.Extra as LE
import Messages exposing (Msg(TableMsg), TableMsg(GoToPage, UpdateFilter))
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Rocket exposing ((=>))


-- Model


type alias Model =
    { filter : Regex.Regex
    , page : Int
    }


initialModel : Model
initialModel =
    { filter = Regex.regex ""
    , page = 1
    }



-- Update


update : TableMsg -> Model -> Model
update msg model =
    case msg of
        UpdateFilter filterText ->
            { model | filter = textToRegex filterText }

        GoToPage page ->
            { model | page = page }



-- Helpers


filterRecord : Regex.Regex -> a -> Bool
filterRecord regex record =
    Regex.contains regex (toString record)


textToRegex : String -> Regex.Regex
textToRegex t =
    t
        |> Regex.escape
        |> Regex.regex
        |> Regex.caseInsensitive



-- View


emptyView : Html Msg
emptyView =
    Html.div [ A.class "alert alert-info" ] [ Html.text "No data to display" ]


defaultTable : Html Msg -> Model -> (a -> ( String, Html Msg )) -> RL.RemoteList a -> Html Msg
defaultTable tableHead tableModel rowConstructor data =
    table "" tableHead tableModel rowConstructor data


table : String -> Html Msg -> Model -> (a -> ( String, Html Msg )) -> RL.RemoteList a -> Html Msg
table tableClass tableHead model rowConstructor data =
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
            Html.div [ A.class "xOverflow" ]
                [ filterInput (TableMsg << UpdateFilter)
                , Html.table [ A.class tableClass ]
                    [ tableHead
                    , Html.Keyed.node "tbody" [] (getPage curPage pages |> List.map rowConstructor)
                    ]
                , pageControls curPage numPages
                ]


filterInput : (String -> msg) -> Html msg
filterInput msg =
    Html.input
        [ A.type_ "text"
        , A.placeholder "Filter..."
        , A.style [ "margin-bottom" => "1rem" ]
        , E.onInput msg
        ]
        []


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
            Html.div [] <|
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
        [ Html.div [ A.class "button", A.disabled True ] [ Html.text "..." ]
        , pageButton (curPage - 1) curPage
        ]


rightButtons : Int -> Int -> List (Html Msg)
rightButtons curPage numPages =
    if curPage == numPages - 1 then
        [ Html.text "" ]
    else
        [ pageButton (curPage + 1) curPage
        , Html.div [ A.class "button", A.disabled True ] [ Html.text "..." ]
        ]


prevButton : Int -> Html Msg
prevButton curPage =
    let
        attrs =
            case curPage == 1 of
                True ->
                    [ A.class "button button-white", A.disabled True ]

                False ->
                    [ A.class "button button-white", A.disabled False, E.onClick <| TableMsg <| GoToPage <| curPage - 1 ]
    in
    Html.button attrs [ Html.i [ A.class "fa fa-chevron-left" ] [] ]


nextButton : Int -> Int -> Html Msg
nextButton curPage numPages =
    let
        attrs =
            case curPage == numPages of
                True ->
                    [ A.class "button button-white", A.disabled True ]

                False ->
                    [ A.class "button button-white", E.onClick <| TableMsg <| GoToPage <| curPage + 1 ]
    in
    Html.button attrs [ Html.i [ A.class "fa fa-chevron-right" ] [] ]


pageButton : Int -> Int -> Html Msg
pageButton goToPage curPage =
    let
        class =
            case curPage == goToPage of
                True ->
                    "button"

                False ->
                    "button button-white"
    in
    Html.a [ A.class class, E.onClick <| TableMsg <| GoToPage goToPage ] [ Html.text (toString goToPage) ]


clampPage : Int -> Int -> Int
clampPage numPages page =
    clamp 1 numPages page
