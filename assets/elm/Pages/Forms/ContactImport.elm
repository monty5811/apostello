module Pages.Forms.ContactImport
    exposing
        ( Model
        , Msg
        , initialModel
        , update
        , view
        )

import Css
import DjangoSend
import Form as F exposing (Field, FormItem(FormField), FormStatus(..), form, longTextField)
import Html exposing (Html)
import Html.Attributes as A
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.ContactImport exposing (meta)
import Urls


-- Model


type alias Model =
    { text : String
    , formStatus : FormStatus
    }


initialModel : Model
initialModel =
    { text = ""
    , formStatus = NoAction
    }



-- Update


type Msg
    = UpdateText String
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        UpdateText text ->
            F.UpdateResp
                { model | text = text }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postContactImportCmd props.csrftoken model.text)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


postContactImportCmd : DjangoSend.CSRFToken -> String -> Cmd Msg
postContactImportCmd csrf csv =
    let
        body =
            [ ( "csv_data", Encode.string csv ) ]
    in
    DjangoSend.rawPost csrf Urls.api_recipients_import_csv body
        |> Http.send ReceiveFormResp



--View


type alias Messages msg =
    { form : Msg -> msg
    }


view : Messages msg -> Model -> Html msg
view msgs model =
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
            model.formStatus
            fields
            (msgs.form PostForm)
            button
        ]
