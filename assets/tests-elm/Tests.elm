module Tests exposing (..)

import Test exposing (..)
import Expect
import Set exposing (Set)
import Helpers exposing (buildQuery, getPeoplePks)
import ApostelloModels exposing (..)
import Models exposing (..)


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
    [ Group 100 "all" [ john, bob, bill ]
    , Group 1 "john" [ john ]
    , Group 2 "bob" [ bob ]
    , Group 3 "bill" [ bill ]
    ]


testPeoplePks : String -> Set Int
testPeoplePks queryString =
    let
        query =
            buildQuery queryString
    in
        getPeoplePks testGroups query Set.empty


all : Test
all =
    describe "Group Composer Test Suite"
        [ test "Union" <|
            \() ->
                Expect.equal (testPeoplePks "2|3") (Set.fromList [ 2, 3 ])
        , test "Intersect" <|
            \() ->
                Expect.equal (testPeoplePks "100 + 2") (Set.fromList [ 2 ])
        , test "Diff" <|
            \() ->
                Expect.equal (testPeoplePks "100-2") (Set.fromList [ 1, 3 ])
        , test "More complicated query" <|
            \() ->
                Expect.equal (testPeoplePks " 2 | 3 - 100") (Set.fromList [])
        ]
