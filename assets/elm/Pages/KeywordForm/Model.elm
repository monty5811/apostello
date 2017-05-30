module Pages.KeywordForm.Model exposing (..)

import Date
import DateTimePicker
import Regex


type alias KeywordFormModel =
    { keyword : Maybe String
    , description : Maybe String
    , disable_all_replies : Maybe Bool
    , custom_response : Maybe String
    , deactivated_response : Maybe String
    , too_early_response : Maybe String
    , activate_time : Maybe Date.Date
    , datePickerActState : DateTimePicker.State
    , deactivate_time : Maybe Date.Date
    , datePickerDeactState : DateTimePicker.State
    , linkedGroupsFilter : Regex.Regex
    , linked_groups : Maybe (List Int)
    , ownersFilter : Regex.Regex
    , owners : Maybe (List Int)
    , subscribersFilter : Regex.Regex
    , subscribers : Maybe (List Int)
    }


initialKeywordFormModel : KeywordFormModel
initialKeywordFormModel =
    { keyword = Nothing
    , description = Nothing
    , disable_all_replies = Nothing
    , custom_response = Nothing
    , deactivated_response = Nothing
    , too_early_response = Nothing
    , activate_time = Nothing
    , datePickerActState = DateTimePicker.initialState
    , deactivate_time = Nothing
    , datePickerDeactState = DateTimePicker.initialState
    , linkedGroupsFilter = Regex.regex ""
    , linked_groups = Nothing
    , ownersFilter = Regex.regex ""
    , owners = Nothing
    , subscribersFilter = Regex.regex ""
    , subscribers = Nothing
    }
