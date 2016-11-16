module Helpers exposing (..)

import ApostelloModels exposing (..)
import Dict
import List.Extra exposing (uncons)
import Models exposing (..)
import Regex exposing (..)
import Set exposing (Set)


-- Run the query to produce new group


runQuery : Model -> ( People, List Int )
runQuery model =
    let
        query =
            model.query
                |> Maybe.withDefault ""
                |> buildQuery

        peoplePks =
            getPeoplePks model.groups query Set.empty

        people =
            model.people
                |> List.filter (\p -> Set.member p.pk peoplePks)
    in
        ( people, query.groupPks )


buildQuery : String -> Query
buildQuery query =
    let
        queryString =
            query
                |> String.append "|"
    in
        { groupPks =
            queryString
                |> find All (regex "\\d+")
                |> List.map .match
                |> List.map String.toInt
                |> List.map (Result.withDefault 0)
        , ops =
            queryString
                |> find All (regex "-|\\+|\\|")
                |> List.map .match
                |> List.map string2Op
        }


getPeoplePks : Groups -> Query -> Set Int -> Set Int
getPeoplePks groups query people =
    if List.isEmpty query.groupPks then
        -- we are done, spit out final set
        people
    else
        let
            ( op, ops ) =
                uncons query.ops
                    |> Maybe.withDefault ( NoOp, [] )

            ( pk, pks ) =
                uncons query.groupPks
                    |> Maybe.withDefault ( 0, [] )
        in
            people
                |> applyOperator groups pk op
                |> getPeoplePks groups { groupPks = pks, ops = ops }


applyOperator : Groups -> Int -> SetOp -> Set Int -> Set Int
applyOperator groups pk op people =
    let
        group =
            groups
                |> List.filter (\x -> x.pk == pk)
                |> List.head
                |> Maybe.withDefault nullGroup

        members =
            group.members
                |> List.map .pk
                |> Set.fromList
    in
        case op of
            Union ->
                Set.union people members

            Intersect ->
                Set.intersect people members

            Diff ->
                Set.diff people members

            NoOp ->
                people


string2Op : String -> SetOp
string2Op string =
    case string of
        "+" ->
            Intersect

        "-" ->
            Diff

        "|" ->
            Union

        _ ->
            NoOp



-- Build the Link


buildGroupLink : People -> String
buildGroupLink people =
    people
        |> List.map (\p -> "recipient=" ++ (toString p.pk))
        |> String.join "&"
        |> String.append "/send/adhoc/?"



-- Collect people pks from groups into single list


collectPeople : Groups -> People
collectPeople groups =
    let
        people =
            groups
                |> List.concatMap (\x -> x.members)
                |> List.map (\x -> ( x.pk, x ))
    in
        Dict.fromList people
            |> Dict.toList
            |> List.map (\x -> Tuple.second x)
