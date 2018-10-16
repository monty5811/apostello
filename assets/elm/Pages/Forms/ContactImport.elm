module Pages.Forms.ContactImport exposing
    ( Model
    , Msg
    , initialModel
    , update
    , view
    )

import Css
import DjangoSend
import Form as F
import Html exposing (Html)
import Html.Attributes as A
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.ContactImport exposing (meta)
import Urls



-- Model


type alias Model =
    { form : F.Form String ()
    }


initialModel : Model
initialModel =
    { form = F.startCreating "" ()
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
                { model | form = F.updateField (updateText text) model.form }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postCmd props.csrftoken model)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateText : String -> String -> () -> ( String, () )
updateText text _ _ =
    ( text, () )


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    case F.getCurrent model.form of
        Just text ->
            let
                body =
                    [ ( "csv_data", Encode.string text ) ]
            in
            DjangoSend.rawPost csrf Urls.api_recipients_import_csv body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none



--View


type alias Messages msg =
    { form : Msg -> msg
    }


view : Messages msg -> Model -> Html msg
view msgs model =
    let
        button =
            \_ -> Html.button [ A.id "formSubmitButton", Css.btn, Css.btn_purple ] [ Html.text "Import" ]
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
        , F.form
            model.form
            (fieldsHelp msgs)
            (msgs.form PostForm)
            button
        ]


fieldsHelp : Messages msg -> F.Item String -> () -> List (F.FormItem msg)
fieldsHelp msgs item _ =
    [ F.longTextField
        20
        { getValue = \n -> n
        , item = item
        , onInput = msgs.form << UpdateText
        }
        |> F.Field meta.csv_data
        |> F.FormField
    ]
