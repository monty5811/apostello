module FilteringTable.Model exposing (Model, initial)

import Regex


type alias Model =
    { filter : Regex.Regex
    , page : Int
    }


initial : Model
initial =
    { filter = Regex.regex ""
    , page = 1
    }
