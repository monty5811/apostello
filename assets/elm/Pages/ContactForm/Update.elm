module Pages.ContactForm.Update exposing (update)

import Pages.ContactForm.Messages exposing (ContactFormMsg(..))
import Pages.ContactForm.Model exposing (ContactFormModel)


update : ContactFormMsg -> ContactFormModel -> ContactFormModel
update msg model =
    case msg of
        UpdateContactFirstNameField text ->
            { model | first_name = Just text }

        UpdateContactLastNameField text ->
            { model | last_name = Just text }

        UpdateContactDoNotReplyField maybeContact ->
            let
                b =
                    case model.do_not_reply of
                        Just curVal ->
                            not curVal

                        Nothing ->
                            case maybeContact of
                                Nothing ->
                                    False

                                Just c ->
                                    not c.do_not_reply
            in
            { model | do_not_reply = Just b }

        UpdateContactNumberField text ->
            { model | number = Just text }
