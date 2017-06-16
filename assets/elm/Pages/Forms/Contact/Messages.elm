module Pages.Forms.Contact.Messages
    exposing
        ( ContactFormMsg
            ( UpdateContactDoNotReplyField
            , UpdateContactFirstNameField
            , UpdateContactLastNameField
            , UpdateContactNumberField
            )
        )

import Data.Recipient exposing (Recipient)


type ContactFormMsg
    = UpdateContactDoNotReplyField (Maybe Recipient)
    | UpdateContactFirstNameField String
    | UpdateContactLastNameField String
    | UpdateContactNumberField String
