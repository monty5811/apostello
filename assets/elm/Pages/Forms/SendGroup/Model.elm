module Pages.Forms.SendGroup.Model exposing (..)

import Date
import DateTimePicker
import Regex


type alias SendGroupModel =
    { content : String
    , date : Maybe Date.Date
    , selectedPk : Maybe Int
    , cost : Maybe Float
    , groupFilter : Regex.Regex
    , datePickerState : DateTimePicker.State
    }


initialSendGroupModel : Maybe String -> Maybe Int -> SendGroupModel
initialSendGroupModel initialContent initialSelectedGroup =
    { content = Maybe.withDefault "" initialContent
    , selectedPk = initialSelectedGroup
    , date = Nothing
    , cost = Nothing
    , groupFilter = Regex.regex ""
    , datePickerState = DateTimePicker.initialState
    }
