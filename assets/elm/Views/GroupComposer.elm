module Views.GroupComposer exposing (view, runQuery, parenPairs, parseQueryString)

import Array
import Dict
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style, type_, value)
import Html.Events exposing (onInput, onClick)
import List.Extra exposing (findIndices)
import Messages exposing (Msg(LoadData, GroupComposerMsg), GroupComposerMsg(UpdateQueryString))
import Models exposing (GroupComposerModel, RecipientGroup, GroupPk, Groups, nullGroup, QueryOp(..), Query, ParenLoc, PeopleSimple, RecipientSimple)
import Pages exposing (Page(SendAdhoc))
import Regex exposing (regex)
import Route exposing (page2loc)
import Set exposing (Set)


-- Main view


view : GroupComposerModel -> List RecipientGroup -> Html Msg
view model groups =
    let
        ( activePeople, activeGroupPks ) =
            runQuery groups (collectPeople groups) (Maybe.withDefault "" model.query)
    in
        div [ class "ui grid" ]
            [ div [ class "row" ] [ helpView ]
            , div [ class "row" ] [ queryEntry model.query ]
            , dataView groups activePeople activeGroupPks
            ]



-- Collect people from all groups


collectPeople : Groups -> PeopleSimple
collectPeople groups =
    groups
        |> List.concatMap (\x -> x.members)
        |> List.map (\x -> ( x.pk, x ))
        |> Dict.fromList
        |> Dict.toList
        |> List.map (\x -> Tuple.second x)
        |> List.sortBy .full_name



-- Run the query to produce new group


runQuery : Groups -> PeopleSimple -> String -> ( PeopleSimple, List GroupPk )
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


queryEntry : Maybe String -> Html Msg
queryEntry query =
    div [ class "sixteen wide column" ]
        [ div [ class "ui big fluid input" ]
            [ input
                [ placeholder "Query goes here: e.g. 1 + 2 - 3"
                , type_ "text"
                , onInput <| GroupComposerMsg << UpdateQueryString
                , value (Maybe.withDefault "" query)
                ]
                []
            ]
        ]



-- Data view


dataView : Groups -> PeopleSimple -> List Int -> Html Msg
dataView groups people activeGroupPks =
    div [ class "row" ] [ groupsList groups activeGroupPks, groupPreview people ]



-- Group List


groupsList : Groups -> List Int -> Html Msg
groupsList groups activeGroupPks =
    div [ class "eight wide column" ]
        [ div [ class "ui raised segment" ]
            [ h4 []
                [ text "Groups"
                , div
                    [ class "circular ui grey icon right floated button"
                    ]
                    [ i [ class "icon refresh", onClick LoadData ] []
                    ]
                ]
            , br [] []
            , div [ class "ui divided list" ] <| List.map (groupRow activeGroupPks) groups
            ]
        ]


groupRow : List Int -> RecipientGroup -> Html Msg
groupRow activeGroupPks group =
    div [ class "item", style (activeGroupStyle activeGroupPks group) ]
        [ div [ class "right floated content" ] [ text (toString group.pk) ]
        , div [ class "content" ] [ text group.name ]
        ]


activeGroupStyle : List Int -> RecipientGroup -> List ( String, String )
activeGroupStyle activeGroupPks group =
    case List.member group.pk activeGroupPks of
        True ->
            [ ( "color", "#38AF3C" ) ]

        False ->
            []



-- Preview


groupPreview : PeopleSimple -> Html Msg
groupPreview people =
    div [ class "eight wide column" ]
        [ div [ class "ui raised segment" ]
            [ h4 []
                [ text "Live preview"
                , groupLink people
                ]
            , div [ class "ui list" ] (List.map personRow people)
            ]
        ]


personRow : RecipientSimple -> Html Msg
personRow person =
    div [ class "item" ] [ text person.full_name ]


groupLink : PeopleSimple -> Html Msg
groupLink people =
    if List.isEmpty people then
        div [] []
    else
        a
            [ class "circular ui violet icon right floated button"
            , href <| buildGroupLink people
            ]
            [ i [ class "icon mail" ] []
            ]



-- Help


helpView : Html Msg
helpView =
    div [ class "ui sixteen wide column raised segment" ]
        [ h2 [] [ text "Group Composer" ]
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
        , br [] []
        , p [] [ text "Click the refresh button to reload the groups." ]
        , p [] [ text "Click the purple button to open the adhoc sending page with your group prefilled." ]
        ]



-- Build the Link


buildGroupLink : PeopleSimple -> String
buildGroupLink people =
    people
        |> List.map .pk
        |> Just
        |> SendAdhoc Nothing
        |> page2loc



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
                |> Array.fromList
                |> Array.slice (left + 1) right
                |> Array.toList
                |> (++) [ Union ]
                |> applyQuery Set.empty
                |> G
    in
        replaceOp left right newExpr query


replaceOp : Int -> Int -> QueryOp -> Query -> Query
replaceOp left right op query =
    let
        ar =
            Array.fromList query

        lhs =
            Array.slice 0 left ar
                |> Array.toList

        rhs =
            Array.slice (right + 1) (Array.length ar) ar
                |> Array.toList
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


parseQueryString : Groups -> String -> Query
parseQueryString groups queryString =
    "|"
        ++ queryString
        |> Regex.find Regex.All (regex "\\d+|\\(|\\)|-|\\+|\\|")
        |> List.map .match
        |> List.map (parseOp groups)


selectGroups : String -> List Int
selectGroups queryString =
    queryString
        |> Regex.find Regex.All (regex "\\d+")
        |> List.map .match
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)


parseOp : Groups -> String -> QueryOp
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


decodeGroup : Groups -> String -> QueryOp
decodeGroup groups s =
    case String.toInt s of
        Ok num ->
            G (getMembers groups num)

        Err _ ->
            NoOp


getMembers : Groups -> GroupPk -> Set Int
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
