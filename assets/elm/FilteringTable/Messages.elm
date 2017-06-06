module FilteringTable.Messages exposing (TableMsg(GoToPage, UpdateFilter))


type TableMsg
    = UpdateFilter String
    | GoToPage Int
