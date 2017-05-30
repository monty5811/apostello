module Pages.UserProfileTable.Messages exposing (..)

import Data.User exposing (UserProfile)
import Http


type UserProfileTableMsg
    = ToggleField UserProfile
    | ReceiveToggleProfile (Result Http.Error UserProfile)
