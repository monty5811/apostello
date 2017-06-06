module FilteringTable.Util exposing (filterRecord, textToRegex)

import Regex


filterRecord : Regex.Regex -> a -> Bool
filterRecord regex record =
    Regex.contains regex (toString record)


textToRegex : String -> Regex.Regex
textToRegex t =
    t
        |> Regex.escape
        |> Regex.regex
        |> Regex.caseInsensitive
