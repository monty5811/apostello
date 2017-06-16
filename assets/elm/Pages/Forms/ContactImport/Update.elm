module Pages.Forms.ContactImport.Update exposing (update)

import Pages.Forms.ContactImport.Messages exposing (ContactImportMsg(UpdateText))
import Pages.Forms.ContactImport.Model exposing (ContactImportModel)


update : ContactImportMsg -> ContactImportModel -> ContactImportModel
update msg model =
    case msg of
        UpdateText text ->
            { model | text = text }
