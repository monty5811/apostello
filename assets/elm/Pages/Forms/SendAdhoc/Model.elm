module Pages.Forms.SendAdhoc.Model exposing (..)

import Date
import DateTimePicker
import Regex


type alias SendAdhocModel =
    { content : String
    , selectedContacts : List Int
    , date : Maybe Date.Date
    , adhocFilter : Regex.Regex
    , cost : Maybe Float
    , datePickerState : DateTimePicker.State
    }


initialSendAdhocModel : Maybe String -> Maybe (List Int) -> SendAdhocModel
initialSendAdhocModel maybeContent maybePks =
    { content = Maybe.withDefault "" maybeContent
    , selectedContacts = Maybe.withDefault [] maybePks
    , date = Nothing
    , adhocFilter = Regex.regex ""
    , cost = Nothing
    , datePickerState = DateTimePicker.initialState
    }
