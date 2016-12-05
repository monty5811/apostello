module Tests exposing (..)

import ApostelloModels exposing (..)
import Expect
import Helpers exposing (..)
import Models exposing (..)
import Parser exposing (..)
import Set exposing (Set)
import Test exposing (..)
import Fuzz exposing (..)


john : Person
john =
    Person "John" 1


bob : Person
bob =
    Person "Bob" 2


bill : Person
bill =
    Person "Bill" 3


testGroups : Groups
testGroups =
    [ Group 123 "all" [ john, bob, bill ]
    , Group 1 "john" [ john ]
    , Group 2 "bob" [ bob ]
    , Group 3 "bill" [ bill ]
    , Group 12 "john,bob" [ john, bob ]
    ]


testPeoplePks : String -> Set Int
testPeoplePks queryString =
    let
        ( result, _ ) =
            runQuery testGroups [ john, bob, bill ] queryString
    in
        List.map (\p -> p.pk) result
            |> Set.fromList


callParenPairs : String -> List ParenLoc
callParenPairs s =
    let
        ops =
            parseQueryString [] s
    in
        parenPairs (List.length ops) ops 0 0 []


testParenPairs =
    [ test "simple" <|
        \() ->
            Expect.equal (callParenPairs "()") [ (ParenLoc (Just 1) (Just 2)) ]
    , test "two brackets" <|
        \() ->
            Expect.equal (callParenPairs "()()") [ (ParenLoc (Just 1) (Just 2)), (ParenLoc (Just 3) (Just 4)) ]
    ]


all : Test
all =
    describe "Group Composer Test Suite"
        ([ test "Union" <|
            \() ->
                Expect.equal (testPeoplePks "2|3") (Set.fromList [ 2, 3 ])
         , test "Intersect" <|
            \() ->
                Expect.equal (testPeoplePks "123 + 2") (Set.fromList [ 2 ])
         , test "Diff" <|
            \() ->
                Expect.equal (testPeoplePks "123-2") (Set.fromList [ 1, 3 ])
         , test "More complicated query" <|
            \() ->
                Expect.equal (testPeoplePks " 2 | 3 - 123") (Set.fromList [])
         , test "Simple Bracket" <|
            \() ->
                Expect.equal (testPeoplePks "123 - (1 | 2) ") (Set.fromList [ 3 ])
         , test "Two Simple Brackets" <|
            \() ->
                Expect.equal (testPeoplePks "(123 - 3) - (1 | 2) ") (Set.fromList [])
         , test "Nested Brackets" <|
            \() ->
                Expect.equal (testPeoplePks "(1 | (123-2)) + 3 ") (Set.fromList [ 3 ])
         ]
            ++ testParenPairs
        )
