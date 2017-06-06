module Pages.KeywordForm.Update exposing (update)

import FilteringTable.Util as FT
import Helpers exposing (toggleSelectedPk)
import Pages.KeywordForm.Messages exposing (KeywordFormMsg(..))
import Pages.KeywordForm.Model exposing (KeywordFormModel)


update : KeywordFormMsg -> KeywordFormModel -> KeywordFormModel
update msg model =
    case msg of
        UpdateKeywordKeywordField text ->
            { model | keyword = Just text }

        UpdateKeywordDescField text ->
            { model | description = Just text }

        UpdateKeywordDisableRepliesField maybeKeyword ->
            let
                b =
                    case model.disable_all_replies of
                        Just curVal ->
                            not curVal

                        Nothing ->
                            case maybeKeyword of
                                Nothing ->
                                    False

                                Just c ->
                                    not c.disable_all_replies
            in
            { model | disable_all_replies = Just b }

        UpdateKeywordCustRespField text ->
            { model | custom_response = Just text }

        UpdateKeywordDeacRespField text ->
            { model | deactivated_response = Just text }

        UpdateKeywordTooEarlyRespField text ->
            { model | too_early_response = Just text }

        UpdateActivateTime state maybeDate ->
            { model | activate_time = maybeDate, datePickerActState = state }

        UpdateDeactivateTime state maybeDate ->
            { model | deactivate_time = maybeDate, datePickerDeactState = state }

        UpdateKeywordLinkedGroupsFilter text ->
            { model | linkedGroupsFilter = FT.textToRegex text }

        UpdateSelectedLinkedGroup pks pk ->
            { model | linked_groups = Just <| toggleSelectedPk pk pks }

        UpdateKeywordOwnersFilter text ->
            { model | ownersFilter = FT.textToRegex text }

        UpdateSelectedOwner pks pk ->
            { model | owners = Just <| toggleSelectedPk pk pks }

        UpdateKeywordSubscribersFilter text ->
            { model | subscribersFilter = FT.textToRegex text }

        UpdateSelectedSubscriber pks pk ->
            { model | subscribers = Just <| toggleSelectedPk pk pks }
