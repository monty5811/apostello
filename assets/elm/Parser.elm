module Parser exposing (..)

import ApostelloModels exposing (..)
import Array
import Dict
import List.Extra exposing (uncons, findIndices)
import Models exposing (..)
import Regex exposing (..)
import Set exposing (Set)


applyQuery : Set Int -> Query -> Set Int
applyQuery pks q =
    case handleBrackets q of
        first :: second :: rest ->
            applyOperator first second pks
                |> ((flip applyQuery) rest)

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
        maxLength =
            (List.length query)

        pairs =
            parenPairs maxLength query 0 0 []
    in
        if evenPairs pairs then
            case pairs of
                p1 :: pRest ->
                    replaceExpr query p1
                        |> handleBrackets

                [] ->
                    query
        else
            query


evenPairs : List ParenLoc -> Bool
evenPairs locs =
    List.all (\x -> (not (isNothing x.close))) locs


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
        lhs ++ [ op ] ++ rhs


parenPairs : Int -> Query -> Int -> Int -> List ParenLoc -> List ParenLoc
parenPairs maxL query i depth res =
    let
        nextI =
            i + 1
    in
        if i > maxL then
            res
        else
            case query of
                OpenBracket :: rest ->
                    parenPairs maxL rest nextI (depth + 1) (List.append res [ ParenLoc (Just i) Nothing ])

                CloseBracket :: rest ->
                    parenPairs maxL rest nextI (depth - 1) (replaceLastNothing res i)

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
        Just i ->
            if (i == mapIndex) then
                { t | close = Just bracketIndex }
            else
                t

        Nothing ->
            t


parseQueryString : Groups -> String -> Query
parseQueryString groups queryString =
    "|"
        ++ queryString
        |> find All (regex "\\d+|\\(|\\)|-|\\+|\\|")
        |> List.map .match
        |> List.map (parseOp groups)


selectGroups : String -> List Int
selectGroups queryString =
    queryString
        |> find All (regex "\\d+")
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
    let
        res =
            String.toInt s
    in
        case res of
            Ok num ->
                G (getMembers groups num)

            Err _ ->
                NoOp


getMembers : Groups -> GroupPk -> Set Int
getMembers groups gPk =
    let
        group =
            groups
                |> List.filter (\x -> x.pk == gPk)
                |> List.head
                |> Maybe.withDefault nullGroup
    in
        group.members
            |> List.map .pk
            |> Set.fromList


isNothing : Maybe a -> Bool
isNothing x =
    case x of
        Just _ ->
            False

        Nothing ->
            True
