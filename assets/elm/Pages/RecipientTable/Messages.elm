module Pages.RecipientTable.Messages exposing (..)

import Data.Recipient exposing (Recipient)
import Http


type RecipientTableMsg
    = ToggleRecipientArchive Bool Int
    | ReceiveRecipientToggleArchive (Result Http.Error Recipient)
