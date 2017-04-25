port module Main exposing (main, emit)

import Json.Encode exposing (Value)
import Test exposing (..)
import Test.Runner.Node exposing (run, TestProgram)
import TestGroupComposer
import TestRoute
import TestSerialisation


main : TestProgram
main =
    run emit
        (describe "apostello"
            [ TestGroupComposer.suite
            , TestRoute.suite
            , TestSerialisation.suite
            ]
        )


port emit : ( String, Value ) -> Cmd msg
