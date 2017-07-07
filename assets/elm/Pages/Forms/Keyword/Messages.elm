module Pages.Forms.Keyword.Messages exposing (..)

import Data exposing (Keyword)
import Date
import DateTimePicker


type KeywordFormMsg
    = UpdateKeywordKeywordField String
    | UpdateKeywordDescField String
    | UpdateKeywordDisableRepliesField (Maybe Keyword)
    | UpdateKeywordCustRespField String
    | UpdateKeywordDeacRespField String
    | UpdateKeywordTooEarlyRespField String
    | UpdateActivateTime DateTimePicker.State (Maybe Date.Date)
    | UpdateDeactivateTime DateTimePicker.State (Maybe Date.Date)
    | UpdateKeywordLinkedGroupsFilter String
    | UpdateSelectedLinkedGroup (List Int) Int
    | UpdateKeywordOwnersFilter String
    | UpdateSelectedOwner (List Int) Int
    | UpdateKeywordSubscribersFilter String
    | UpdateSelectedSubscriber (List Int) Int
