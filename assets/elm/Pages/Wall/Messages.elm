module Pages.Wall.Messages exposing (..)

import Data.SmsInbound exposing (SmsInbound)
import Http


type WallMsg
    = ToggleWallDisplay Bool Int
    | ReceiveToggleWallDisplay (Result Http.Error SmsInbound)
