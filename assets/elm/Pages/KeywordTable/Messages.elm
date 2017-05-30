module Pages.KeywordTable.Messages exposing (..)

import Data.Keyword exposing (Keyword)
import Http


type KeywordTableMsg
    = ToggleKeywordArchive Bool String
    | ReceiveToggleKeywordArchive (Result Http.Error Keyword)
