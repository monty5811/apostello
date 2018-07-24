module Pages.Forms.ContactImport
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Css
import Forms.Model exposing (Field, FormItem(FormField), FormStatus)
import Forms.View exposing (form, longTextField)
import Html exposing (Html)
import Html.Attributes as A
import Pages.Forms.Meta.ContactImport exposing (meta)


-- Model


type alias Model =
    String


initialModel : Model
initialModel =
    ""



-- Update


type Msg
    = UpdateText String


update : Msg -> Model
update (UpdateText text) =
    text



--View


type alias Messages msg =
    { form : Msg -> msg
    , post : msg
    }


view : Messages msg -> FormStatus -> Html msg
view msgs formStatus =
    let
        fields =
            [ FormField <| Field meta.csv_data <| longTextField 20 (Just "") (msgs.form << UpdateText)
            ]

        button =
            Html.button [ A.id "formSubmitButton", Css.btn, Css.btn_purple ] [ Html.text "Import" ]
    in
    Html.div [ Css.max_w_md, Css.mx_auto ]
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
            formStatus
            fields
            msgs.post
            button
        ]
