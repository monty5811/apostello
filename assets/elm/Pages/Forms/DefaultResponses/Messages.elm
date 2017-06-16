module Pages.Forms.DefaultResponses.Messages exposing (DefaultResponsesFormMsg(..))

import Pages.Forms.DefaultResponses.Model exposing (DefaultResponsesFormModel)


type DefaultResponsesFormMsg
    = UpdateField (String -> DefaultResponsesFormModel) String
