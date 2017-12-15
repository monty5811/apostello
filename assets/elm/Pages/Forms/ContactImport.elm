module Pages.Forms.ContactImport exposing (Msg(UpdateText), update, view)

import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (form, longTextField)
import Html exposing (Html)
import Html.Attributes as A
import Pages.Forms.Meta.ContactImport exposing (meta)


-- Update


type Msg
    = UpdateText String


update : Msg -> String
update (UpdateText text) =
    text



--View


type alias Messages msg =
    { form : Msg -> msg
    , post : msg
    }


view : Messages msg -> FormStatus -> Html msg
view msgs status =
    let
        fields =
            [ FormField <| Field meta.csv_data <| longTextField 20 (Just "") (msgs.form << UpdateText)
            ]

        button =
            Html.button [ A.class <| "button", A.id "formSubmitButton" ] [ Html.text "Import" ]
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
            msgs.post
            button
        ]
