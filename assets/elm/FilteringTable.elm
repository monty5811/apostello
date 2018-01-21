module FilteringTable
    exposing
        ( Model
        , Msg
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
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL


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


type Msg
    = UpdateFilter String
    | GoToPage Int


update : Msg -> Model -> Model
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


emptyView : Html msg
emptyView =
    Html.div [ A.class "alert alert-info" ] [ Html.text "No data to display" ]


defaultTable : Messages msg -> Html msg -> Model -> (a -> ( String, Html msg )) -> RL.RemoteList a -> Html msg
defaultTable msgs tableHead tableModel rowConstructor data =
    table msgs "" tableHead tableModel rowConstructor data


type alias Messages msg =
    { top : Msg -> msg
    }


table : Messages msg -> String -> Html msg -> Model -> (a -> ( String, Html msg )) -> RL.RemoteList a -> Html msg
table msgs tableClass tableHead model rowConstructor data =
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
                [ filterInput (msgs.top << UpdateFilter)
                , Html.table [ A.class tableClass ]
                    [ tableHead
                    , Html.Keyed.node "tbody" [] (getPage curPage pages |> List.map rowConstructor)
                    ]
                , pageControls msgs curPage numPages
                ]


filterInput : (String -> msg) -> Html msg
filterInput msg =
    Html.input
        [ A.type_ "text"
        , A.placeholder "Filter..."
        , A.style [ ( "margin-bottom", "1rem" ) ]
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


pageControls : Messages msg -> Int -> Int -> Html msg
pageControls msgs page numPages =
    case numPages < 2 of
        True ->
            Html.text ""

        False ->
            Html.div [] <|
                buttons msgs page numPages


buttons : Messages msg -> Int -> Int -> List (Html msg)
buttons msgs curPage numPages =
    let
        middleButtons =
            if curPage == 1 then
                List.concat
                    [ [ pageButton msgs 1 curPage ]
                    , rightButtons msgs curPage numPages
                    , [ pageButton msgs numPages curPage ]
                    ]
            else if curPage == numPages then
                List.concat
                    [ [ pageButton msgs 1 curPage ]
                    , leftButtons msgs curPage
                    , [ pageButton msgs numPages curPage ]
                    ]
            else
                List.concat
                    [ [ pageButton msgs 1 curPage ]
                    , leftButtons msgs curPage
                    , [ pageButton msgs curPage curPage ]
                    , rightButtons msgs curPage numPages
                    , [ pageButton msgs numPages curPage ]
                    ]
    in
    List.concat
        [ [ prevButton msgs curPage ]
        , middleButtons
        , [ nextButton msgs curPage numPages ]
        ]


leftButtons : Messages msg -> Int -> List (Html msg)
leftButtons msgs curPage =
    if curPage == 2 then
        [ Html.text "" ]
    else
        [ Html.div [ A.class "button", A.disabled True ] [ Html.text "..." ]
        , pageButton msgs (curPage - 1) curPage
        ]


rightButtons : Messages msg -> Int -> Int -> List (Html msg)
rightButtons msgs curPage numPages =
    if curPage == numPages - 1 then
        [ Html.text "" ]
    else
        [ pageButton msgs (curPage + 1) curPage
        , Html.div [ A.class "button", A.disabled True ] [ Html.text "..." ]
        ]


prevButton : Messages msg -> Int -> Html msg
prevButton msgs curPage =
    let
        attrs =
            case curPage == 1 of
                True ->
                    [ A.class "button button-white", A.disabled True ]

                False ->
                    [ A.class "button button-white", A.disabled False, E.onClick <| msgs.top <| GoToPage <| curPage - 1 ]
    in
    Html.button attrs [ Html.i [ A.class "fa fa-chevron-left" ] [] ]


nextButton : Messages msg -> Int -> Int -> Html msg
nextButton msgs curPage numPages =
    let
        attrs =
            case curPage == numPages of
                True ->
                    [ A.class "button button-white", A.disabled True ]

                False ->
                    [ A.class "button button-white", E.onClick <| msgs.top <| GoToPage <| curPage + 1 ]
    in
    Html.button attrs [ Html.i [ A.class "fa fa-chevron-right" ] [] ]


pageButton : Messages msg -> Int -> Int -> Html msg
pageButton msgs goToPage curPage =
    let
        class =
            case curPage == goToPage of
                True ->
                    "button"

                False ->
                    "button button-white"
    in
    Html.a [ A.class class, E.onClick <| msgs.top <| GoToPage goToPage ] [ Html.text (toString goToPage) ]


clampPage : Int -> Int -> Int
clampPage numPages page =
    clamp 1 numPages page
