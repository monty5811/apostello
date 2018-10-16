module Future.String exposing (fromFloat, fromInt)


fromInt : Int -> String
fromInt i =
    toString i


fromFloat : Float -> String
fromFloat f =
    toString f
