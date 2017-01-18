module Tests exposing (..)

import Common.Models exposing (..)
import Expect
import GroupComposer.Helpers exposing (..)
import GroupComposer.Models exposing (..)
import GroupComposer.Parser exposing (..)
import Set exposing (Set)
import Test exposing (..)
import Fuzz exposing (..)


john : RecipientSimple
john =
    RecipientSimple "John" 1


bob : RecipientSimple
bob =
    RecipientSimple "Bob" 2


bill : RecipientSimple
bill =
    RecipientSimple "Bill" 3


testGroups : Groups
testGroups =
    [ RecipientGroup "all" 123 "" [ john, bob, bill ] [] "" "" False
    , RecipientGroup "john" 1 "" [ john ] [] "" "" False
    , RecipientGroup "bob" 2 "" [ bob ] [] "" "" False
    , RecipientGroup "bill" 3 "" [ bill ] [] "" "" False
    , RecipientGroup "john,bob" 12 "" [ john, bob ] [] "" "" False
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
    describe "RecipientGroup Composer Test Suite"
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
