module Pages.Forms.SendGroup.Messages exposing (..)

import Date
import DateTimePicker


type SendGroupMsg
    = UpdateSGContent String
    | UpdateSGDate DateTimePicker.State (Maybe Date.Date)
    | SelectGroup Int
    | UpdateGroupFilter String
