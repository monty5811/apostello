module Pages.Forms.SendAdhoc.Messages
    exposing
        ( SendAdhocMsg
            ( ToggleSelectedContact
            , UpdateAdhocFilter
            , UpdateContent
            , UpdateDate
            )
        )

import Date
import DateTimePicker


type SendAdhocMsg
    = UpdateContent String
    | UpdateDate DateTimePicker.State (Maybe Date.Date)
    | ToggleSelectedContact Int
    | UpdateAdhocFilter String
