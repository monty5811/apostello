module Pages.Forms.ContactImport.Model exposing (ContactImportModel, initialContactImportModel)


type alias ContactImportModel =
    { text : String
    }


initialContactImportModel : ContactImportModel
initialContactImportModel =
    { text = "" }
