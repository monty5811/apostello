module Pages.Forms.ContactImport.View exposing (view)

import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (form, longTextField)
import Html exposing (Html)
import Html.Attributes as A
import Messages exposing (FormMsg(ContactImportMsg, PostForm), Msg(FormMsg))
import Pages.Forms.ContactImport.Messages exposing (ContactImportMsg(UpdateText))
import Pages.Forms.ContactImport.Meta exposing (meta)
import Pages.Forms.ContactImport.Model exposing (ContactImportModel)
import Pages.Forms.ContactImport.Remote exposing (postCmd)


view : CSRFToken -> FormStatus -> ContactImportModel -> Html Msg
view csrf status model =
    let
        fields =
            [ Field meta.csv_data <| longTextField 20 meta.csv_data (Just "") (FormMsg << ContactImportMsg << UpdateText)
            ]

        button =
            Html.button [ A.class <| "ui primary button" ] [ Html.text "Import" ]
    in
    Html.div []
        [ Html.p []
            [ Html.text "Bulk import contacts."
            ]
        , Html.p []
            [ Html.text "Paste a CSV data into the box below."
            ]
        , Html.p []
            [ Html.text "There should be no header row and there should be three columns: First Name, Last Name, Number"
            ]
        , form
            status
            fields
            (FormMsg <| PostForm <| postCmd csrf model.text)
            button
        ]
