port module Ports exposing (loadDataStore, saveDataStore)

import Json.Encode as Encode


port saveDataStore : Encode.Value -> Cmd msg


port loadDataStore : (String -> msg) -> Sub msg
