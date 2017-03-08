port module Ports exposing (..)

import Json.Encode as Encode


port updateDateValue : (String -> msg) -> Sub msg


port saveDataStore : Encode.Value -> Cmd msg


port loadDataStore : (String -> msg) -> Sub msg
