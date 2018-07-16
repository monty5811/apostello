module Pages.GroupComposer
    exposing
        ( Model
        , Msg
        , ParenLoc
        , initialModel
        , parenPairs
        , parseQueryString
        , runQuery
        , update
        , view
        )

import Css
import Data exposing (GroupPk, RecipientGroup, RecipientSimple, nullGroup)
import Html exposing (..)
import Html.Attributes as A
import Html.Events as E
import List.Extra exposing (findIndices, uniqueBy)
import Regex exposing (regex)
import RemoteList as RL
import Set exposing (Set)


type alias Model =
    Maybe String


initialModel : Model
initialModel =
    Nothing


type alias Query =
    List QueryOp


type QueryOp
    = Union
    | Intersect
    | Diff
    | OpenBracket
    | CloseBracket
    | G (Set Int)
    | NoOp


type alias ParenLoc =
    { open : Maybe Int
    , close : Maybe Int
    }



-- Update


type Msg
    = UpdateQueryString String


update : Msg -> Maybe String
update (UpdateQueryString text) =
    Just text



-- View


type alias Props msg =
    { form : Msg -> msg
    , groupLink : Maybe (List Int) -> Html msg
    }


view : Props msg -> Model -> RL.RemoteList RecipientGroup -> Html msg
view props model groups_ =
    let
        groups =
            RL.toList groups_

        ( activePeople, activeGroupPks ) =
            runQuery groups (collectPeople groups) (Maybe.withDefault "" model)
    in
    Html.div [ Css.mx_4 ]
        [ Html.div [ Css.notRaisedSegment ] helpView
        , Html.div [ A.class "px-4 m-1" ] [ queryEntry props model ]
        , dataView props groups activePeople activeGroupPks
        ]



-- Collect people from all groups


collectPeople : List RecipientGroup -> List RecipientSimple
collectPeople groups =
    groups
        |> List.concatMap (\x -> x.members)
        |> uniqueBy .pk
        |> List.sortBy .full_name



-- Run the query to produce new group


runQuery : List RecipientGroup -> List RecipientSimple -> String -> ( List RecipientSimple, List GroupPk )
runQuery groups people queryString =
    let
        selectedGroups =
            selectGroups queryString

        peoplePks =
            parseQueryString groups queryString
                |> applyQuery Set.empty

        result =
            people
                |> List.filter (\person -> Set.member person.pk peoplePks)
    in
    ( result, selectedGroups )



-- Query view


queryEntry : Props msg -> Maybe String -> Html msg
queryEntry props query =
    input
        [ A.placeholder "Query goes here: e.g. 1 + 2 - 3"
        , A.type_ "text"
        , A.id "queryInputBox"
        , E.onInput <| props.form << UpdateQueryString
        , A.value (Maybe.withDefault "" query)
        , Css.formInput
        ]
        []



-- Data view


dataView : Props msg -> List RecipientGroup -> List RecipientSimple -> List Int -> Html msg
dataView props groups people activeGroupPks =
    Html.div
        [ Css.flex
        , Css.notRaisedSegment
        ]
        [ groupsList props groups activeGroupPks, groupPreview props people ]



-- Group List


groupsList : Props msg -> List RecipientGroup -> List Int -> Html msg
groupsList props groups activeGroupPks =
    Html.div [ Css.w_full, Css.px_2 ]
        [ h4 [] [ text "Groups" ]
        , br [] []
        , Html.div [] <| List.map (groupRow activeGroupPks) groups
        ]


groupRow : List Int -> RecipientGroup -> Html msg
groupRow activeGroupPks group =
    Html.div
        ([ A.id "groupRow"
         , Css.border_b_2
         ]
            ++ activeGroupStyle activeGroupPks group
        )
        [ Html.span [] [ text group.name ]
        , Html.span [ Css.float_right ] [ text (toString group.pk) ]
        ]


activeGroupStyle : List Int -> RecipientGroup -> List (Html.Attribute msg)
activeGroupStyle activeGroupPks group =
    case List.member group.pk activeGroupPks of
        True ->
            [ Css.text_green ]

        False ->
            []



-- Preview


groupPreview : Props msg -> List RecipientSimple -> Html msg
groupPreview props people =
    Html.div [ Css.w_full, Css.px_2 ]
        [ h4 []
            [ text "Live preview"
            , groupLink props people
            ]
        , br [] []
        , Html.div [] (List.map personRow people)
        ]


personRow : RecipientSimple -> Html msg
personRow person =
    Html.div [ Css.border_b_2 ] [ text person.full_name ]


groupLink : Props msg -> List RecipientSimple -> Html msg
groupLink props people =
    if List.isEmpty people then
        Html.div [] []
    else
        people
            |> List.map .pk
            |> Just
            |> props.groupLink



-- Help


helpView : List (Html msg)
helpView =
    [ h2 [ Css.mb_2 ] [ text "Group Composer" ]
    , p []
        [ text "You can use this tool to \"compose\" an adhoc group." ]
    , p
        []
        [ text "Enter a query in the box below. E.g. \"1|2\" would result in a group made up of everyone in group 1 as well as everyone in group 2." ]
    , p
        []
        [ text "There are 3 operators available:" ]
    , ul
        []
        [ li [] [ b [] [ text "|" ], text " : Keep all members (union)" ]
        , li [] [ b [] [ text "+" ], text " : Keep members that are in both (intersect)" ]
        , li [] [ b [] [ text "-" ], text " : Keep member that do not exist on right hand side (diff)" ]
        ]
    , p [] [ text "The operators are applied from left to right. Use brackets to build more complex queries." ]
    , p [] [ text "The best thing to do is experiment and use the live preview." ]
    ]



--Parser


applyQuery : Set Int -> Query -> Set Int
applyQuery pks q =
    case handleBrackets q of
        first :: second :: rest ->
            applyOperator first second pks
                |> flip applyQuery rest

        _ :: [] ->
            pks

        [] ->
            pks


applyOperator : QueryOp -> QueryOp -> Set Int -> Set Int
applyOperator opL opR existingPeople =
    let
        newPeople =
            case opR of
                G members ->
                    members

                _ ->
                    Set.empty
    in
    case opL of
        Union ->
            Set.union existingPeople newPeople

        Intersect ->
            Set.intersect existingPeople newPeople

        Diff ->
            Set.diff existingPeople newPeople

        _ ->
            existingPeople


handleBrackets : Query -> Query
handleBrackets query =
    let
        pairs =
            parenPairs (List.length query) query 0 0 []
    in
    if evenPairs pairs then
        case pairs of
            p1 :: _ ->
                replaceExpr query p1
                    |> handleBrackets

            [] ->
                query
    else
        query


evenPairs : List ParenLoc -> Bool
evenPairs locs =
    List.all (\x -> not (isNothing x.close)) locs


replaceExpr : Query -> ParenLoc -> Query
replaceExpr query pLoc =
    let
        left =
            Maybe.withDefault 0 pLoc.open

        right =
            Maybe.withDefault 0 pLoc.close

        newExpr =
            query
                |> slice (left + 1) right
                |> (++) [ Union ]
                |> applyQuery Set.empty
                |> G
    in
    replaceOp left right newExpr query


slice : Int -> Int -> List a -> List a
slice left right list =
    list
        |> List.indexedMap (,)
        |> List.filterMap (shouldKeepHelp left right)


shouldKeepHelp : Int -> Int -> ( Int, a ) -> Maybe a
shouldKeepHelp left right ( idx, item ) =
    if (idx >= left) && (idx < right) then
        Just item
    else
        Nothing


replaceOp : Int -> Int -> QueryOp -> Query -> Query
replaceOp left right op query =
    let
        lhs =
            slice 0 left query

        rhs =
            slice (right + 1) (List.length query) query
    in
    List.concat [ lhs, [ op ], rhs ]


parenPairs : Int -> Query -> Int -> Int -> List ParenLoc -> List ParenLoc
parenPairs maxL query idx depth res =
    let
        nextI =
            idx + 1
    in
    if idx > maxL then
        res
    else
        case query of
            OpenBracket :: rest ->
                parenPairs maxL rest nextI (depth + 1) (List.append res [ ParenLoc (Just idx) Nothing ])

            CloseBracket :: rest ->
                parenPairs maxL rest nextI (depth - 1) (replaceLastNothing res idx)

            _ :: rest ->
                parenPairs maxL rest nextI depth res

            [] ->
                res


replaceLastNothing : List ParenLoc -> Int -> List ParenLoc
replaceLastNothing res bracketIndex =
    let
        resIndex =
            res
                |> findIndices (\x -> isNothing x.close)
                |> List.maximum
    in
    res
        |> List.indexedMap (updateMatchedLoc bracketIndex resIndex)


updateMatchedLoc : Int -> Maybe Int -> Int -> ParenLoc -> ParenLoc
updateMatchedLoc bracketIndex nothingIndex mapIndex t =
    case nothingIndex of
        Just idx ->
            if idx == mapIndex then
                { t | close = Just bracketIndex }
            else
                t

        Nothing ->
            t


parseQueryString : List RecipientGroup -> String -> Query
parseQueryString groups queryString =
    "|"
        ++ queryString
        |> Regex.find Regex.All (regex "\\d+|\\(|\\)|-|\\+|\\|")
        |> List.map (.match >> parseOp groups)


selectGroups : String -> List Int
selectGroups queryString =
    queryString
        |> Regex.find Regex.All (regex "\\d+")
        |> List.map (.match >> String.toInt >> Result.withDefault 0)


parseOp : List RecipientGroup -> String -> QueryOp
parseOp groups string =
    case string of
        "+" ->
            Intersect

        "-" ->
            Diff

        "|" ->
            Union

        "(" ->
            OpenBracket

        ")" ->
            CloseBracket

        _ ->
            decodeGroup groups string


decodeGroup : List RecipientGroup -> String -> QueryOp
decodeGroup groups s =
    case String.toInt s of
        Ok num ->
            G (getMembers groups num)

        Err _ ->
            NoOp


getMembers : List RecipientGroup -> GroupPk -> Set Int
getMembers groups gPk =
    groups
        |> List.filter (\x -> x.pk == gPk)
        |> List.head
        |> Maybe.withDefault nullGroup
        |> .members
        |> List.map .pk
        |> Set.fromList


isNothing : Maybe a -> Bool
isNothing x =
    case x of
        Just _ ->
            False

        Nothing ->
            True
