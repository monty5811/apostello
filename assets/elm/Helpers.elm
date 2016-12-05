module Helpers exposing (..)

import ApostelloModels exposing (..)
import Dict
import Set exposing (Set)
import Array
import Parser exposing (..)


-- Run the query to produce new group


runQuery : Groups -> People -> String -> ( People, List GroupPk )
runQuery groups people queryString =
    let
        selectedGroups =
            selectGroups queryString

        peoplePks =
            parseQueryString groups queryString
                |> applyQuery Set.empty

        result =
            people
                |> List.filter (\p -> Set.member p.pk peoplePks)
    in
        ( result, selectedGroups )



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
