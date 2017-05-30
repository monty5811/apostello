module Pages.GroupTable.Messages exposing (..)

import Data.RecipientGroup exposing (RecipientGroup)
import Http


type GroupTableMsg
    = ToggleGroupArchive Bool Int
    | ReceiveToggleGroupArchive (Result Http.Error RecipientGroup)
