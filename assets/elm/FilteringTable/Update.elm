module FilteringTable.Update exposing (update)

import FilteringTable.Messages exposing (TableMsg(GoToPage, UpdateFilter))
import FilteringTable.Model exposing (Model)
import FilteringTable.Util exposing (textToRegex)


update : TableMsg -> Model -> Model
update msg model =
    case msg of
        UpdateFilter filterText ->
            { model | filter = textToRegex filterText }

        GoToPage page ->
            { model | page = page }
