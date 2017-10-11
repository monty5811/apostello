module Pages.Forms.Meta.ContactImport exposing (meta)

import Forms.Model exposing (FieldMeta)


meta : { csv_data : FieldMeta }
meta =
    { csv_data = FieldMeta True "id_csv_data" "csv_data" "CSV Data" (Just "John, Calvin, +447095237960")
    }
