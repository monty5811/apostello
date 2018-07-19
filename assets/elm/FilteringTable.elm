module FilteringTable
    exposing
        ( Cell
        , Head
        , Model
        , Msg
        , Row
        , defaultTable
        , filterInput
        , filterRecord
        , initialModel
        , table
        , textToRegex
        , update
        )

import Css
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
    , numberOfRows : Int
    }


initialModel : Model
initialModel =
    { filter = Regex.regex ""
    , page = 1
    , numberOfRows = 50
    }


type alias Row msg =
    { classes : List (Html.Attribute msg)
    , cells : List (Cell msg)
    , key : String
    }


type alias Cell msg =
    { classes : List (Html.Attribute msg)
    , content : List (Html msg)
    }


type alias Head =
    { headings : List String }



-- Update


type Msg
    = UpdateFilter String
    | UpdateNumRows Int
    | GoToPage Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateFilter filterText ->
            { model | filter = textToRegex filterText }

        UpdateNumRows numberOfRows ->
            { model | numberOfRows = numberOfRows }

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
    Html.div [ Css.px_4, Css.py_3, Css.bg_blue, Css.text_white ] [ Html.text "No data to display" ]


defaultTable : Messages msg -> Head -> Model -> (a -> Row msg) -> RL.RemoteList a -> Html msg
defaultTable msgs tableHead tableModel rowConstructor data =
    table msgs [] tableHead tableModel rowConstructor data


type alias Messages msg =
    { top : Msg -> msg
    }


table : Messages msg -> List (Html.Attribute msg) -> Head -> Model -> (a -> Row msg) -> RL.RemoteList a -> Html msg
table msgs tableAttrs tableHead model rowConstructor data =
    let
        items =
            RL.toList data

        filteredItems =
            List.filter (filterRecord model.filter) items

        pages =
            paginate model.numberOfRows filteredItems

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
                [ Html.div [ Css.flex, Css.items_center ]
                    [ filterInput (msgs.top << UpdateFilter)
                    , numRowsInput model.numberOfRows (msgs.top << UpdateNumRows)
                    ]
                , Html.table tableAttrs
                    [ head tableHead
                    , Html.Keyed.node "tbody" [] (getPage curPage pages |> List.map (rowConstructor >> row))
                    ]
                , pageControls msgs curPage numPages
                ]


row : Row msg -> ( String, Html msg )
row r =
    ( r.key, Html.tr ([] ++ r.classes) (List.map cell r.cells) )


cell : Cell msg -> Html msg
cell c =
    Html.td c.classes c.content


head : Head -> Html msg
head h =
    Html.thead [ Css.text_left ]
        [ Html.tr [] <| List.map (Html.text >> List.singleton >> Html.th []) h.headings ]


filterInput : (String -> msg) -> Html msg
filterInput msg =
    Html.input
        [ A.type_ "text"
        , A.placeholder "Filter..."
        , E.onInput msg
        , Css.filterBox
        ]
        []


numRowsInput : Int -> (Int -> msg) -> Html msg
numRowsInput numberOfRowsSelected tagger =
    List.map (selectNumRows numberOfRowsSelected tagger) [ 10, 50, 100, 1000 ]
        |> List.intersperse (Html.text ", ")
        |> Html.div
            [ Css.flex
            , Css.ml_auto
            , Css.mb_4
            , Css.text_sm
            ]


selectNumRows : Int -> (Int -> msg) -> Int -> Html msg
selectNumRows numberOfRowsSelected tagger n =
    Html.div
        [ E.onClick <| tagger n
        , Css.select_none
        , Css.cursor_pointer
        , if numberOfRowsSelected == n then
            Css.font_bold
          else
            Css.noop
        ]
        [ Html.text <| toString n ]


paginate : Int -> List a -> List (List a)
paginate numRows rows =
    LE.greedyGroupsOf numRows rows


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
            Html.div [ Css.p_4, Css.flex ] <|
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
        [ Html.div [ Css.py_2, Css.px_4, A.disabled True ] [ Html.text "..." ]
        , pageButton msgs (curPage - 1) curPage
        ]


rightButtons : Messages msg -> Int -> Int -> List (Html msg)
rightButtons msgs curPage numPages =
    if curPage == numPages - 1 then
        [ Html.text "" ]
    else
        [ pageButton msgs (curPage + 1) curPage
        , Html.div [ Css.py_2, Css.px_4, A.disabled True ] [ Html.text "..." ]
        ]


prevButton : Messages msg -> Int -> Html msg
prevButton msgs curPage =
    let
        attrs =
            case curPage == 1 of
                True ->
                    [ Css.border_2, Css.py_2, Css.px_4, A.disabled True ]

                False ->
                    [ Css.border_2, Css.py_2, Css.px_4, A.disabled False, E.onClick <| msgs.top <| GoToPage <| curPage - 1 ]
    in
    Html.button attrs [ Html.i [ A.class "fa fa-chevron-left" ] [] ]


nextButton : Messages msg -> Int -> Int -> Html msg
nextButton msgs curPage numPages =
    let
        attrs =
            case curPage == numPages of
                True ->
                    [ Css.border_2, Css.py_2, Css.px_4, A.disabled True ]

                False ->
                    [ Css.border_2, Css.py_2, Css.px_4, E.onClick <| msgs.top <| GoToPage <| curPage + 1 ]
    in
    Html.button attrs [ Html.i [ A.class "fa fa-chevron-right" ] [] ]


pageButton : Messages msg -> Int -> Int -> Html msg
pageButton msgs goToPage curPage =
    let
        class =
            case curPage == goToPage of
                True ->
                    [ Css.text_purple, Css.select_none ]

                False ->
                    [ Css.text_black, Css.cursor_pointer ]
    in
    Html.a
        (class
            ++ [ Css.border_2
               , Css.py_2
               , Css.px_4
               , E.onClick <| msgs.top <| GoToPage goToPage
               ]
        )
        [ Html.text (toString goToPage) ]


clampPage : Int -> Int -> Int
clampPage numPages page =
    clamp 1 numPages page
