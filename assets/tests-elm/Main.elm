port module Main exposing (..)

import Json.Encode exposing (Value)
import Test exposing (..)
import Test.Runner.Node exposing (run, TestProgram)
import TestGroupComposer
import TestRoute


main : TestProgram
main =
    run emit
        (describe "apostello" [ TestGroupComposer.suite, TestRoute.suite ])


port emit : ( String, Value ) -> Cmd msg
