module Pages.Forms.Contact.Model exposing (..)


type alias ContactFormModel =
    { first_name : Maybe String
    , last_name : Maybe String
    , number : Maybe String
    , do_not_reply : Maybe Bool
    }


initialContactFormModel : ContactFormModel
initialContactFormModel =
    { first_name = Nothing
    , last_name = Nothing
    , number = Nothing
    , do_not_reply = Nothing
    }
