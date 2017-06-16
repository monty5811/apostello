module Pages.Forms.DefaultResponses.Update exposing (update)

import Pages.Forms.DefaultResponses.Messages exposing (DefaultResponsesFormMsg(..))
import Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel)


update : DefaultResponsesFormMsg -> DefaultResponsesFormModel
update msg =
    case msg of
        UpdateField updater text ->
            updater text
