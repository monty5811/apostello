module Pages.Forms.UserProfile.Update exposing (update)

import Pages.Forms.UserProfile.Messages exposing (UserProfileFormMsg(..))
import Pages.Forms.UserProfile.Model exposing (UserProfileFormModel)


update : UserProfileFormMsg -> UserProfileFormModel -> UserProfileFormModel
update msg model =
    case msg of
        UpdateApproved maybeProfile ->
            { model | approved = getNewBool model.approved (Maybe.map .approved maybeProfile) }

        UpdateCanSeeGroups maybeProfile ->
            { model | can_see_groups = getNewBool model.can_see_groups (Maybe.map .can_see_groups maybeProfile) }

        UpdateCanSeeContactNames maybeProfile ->
            { model | can_see_contact_names = getNewBool model.can_see_contact_names (Maybe.map .can_see_contact_names maybeProfile) }

        UpdateCanSeeKeywords maybeProfile ->
            { model | can_see_keywords = getNewBool model.can_see_keywords (Maybe.map .can_see_keywords maybeProfile) }

        UpdateCanSeeOutgoing maybeProfile ->
            { model | can_see_outgoing = getNewBool model.can_see_outgoing (Maybe.map .can_see_outgoing maybeProfile) }

        UpdateCanSeeIncoming maybeProfile ->
            { model | can_see_incoming = getNewBool model.can_see_incoming (Maybe.map .can_see_incoming maybeProfile) }

        UpdateCanSendSms maybeProfile ->
            { model | can_send_sms = getNewBool model.can_send_sms (Maybe.map .can_send_sms maybeProfile) }

        UpdateCanSeeContactNums maybeProfile ->
            { model | can_see_contact_nums = getNewBool model.can_see_contact_nums (Maybe.map .can_see_contact_nums maybeProfile) }

        UpdateCanImport maybeProfile ->
            { model | can_import = getNewBool model.can_import (Maybe.map .can_import maybeProfile) }

        UpdateCanArchive maybeProfile ->
            { model | can_archive = getNewBool model.can_archive (Maybe.map .can_archive maybeProfile) }

        UpdateMessageCostLimit text ->
            case String.toFloat text of
                Ok num ->
                    { model | message_cost_limit = Just num }

                Err _ ->
                    model


getNewBool : Maybe Bool -> Maybe Bool -> Maybe Bool
getNewBool modelVal profileVal =
    case modelVal of
        Just curVal ->
            -- we haev edited the form, toggle the val
            Just <| not curVal

        Nothing ->
            -- we have not edited the form yet, toggle if we have a saved profile
            Maybe.map not profileVal
