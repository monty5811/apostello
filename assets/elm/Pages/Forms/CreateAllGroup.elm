module Pages.Forms.CreateAllGroup exposing (Model, Msg(..), initialModel, update, view)

import DjangoSend
import Form as F
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.CreateAllGroup exposing (meta)
import Urls


type alias Model =
    { form : F.Form String ()
    }


initialModel : Model
initialModel =
    { form = F.startCreating "" ()
    }



-- Update


type Msg
    = UpdateGroupName String
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        UpdateGroupName name ->
            F.UpdateResp
                { model | form = F.updateField (updateName name) model.form }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postFormCmd props.csrftoken model)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateName : String -> String -> () -> ( String, () )
updateName name _ _ =
    ( name, () )


postFormCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postFormCmd csrf model =
    case F.getCurrent model.form of
        Just name ->
            let
                body =
                    [ ( "group_name", Encode.string name ) ]
            in
            DjangoSend.rawPost csrf Urls.api_act_create_all_group body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none



-- View


type alias Messages msg =
    { form : Msg -> msg
    }


view : Messages msg -> Model -> Html msg
view msgs model =
    Html.div []
        [ Html.p [] [ Html.text "You can use this F.form to create a new group that contains all currently active contacts." ]
        , F.form
            model.form
            (fieldsHelp msgs)
            (msgs.form PostForm)
            F.submitButton
        ]


fieldsHelp : Messages msg -> F.Item String -> () -> List (F.FormItem msg)
fieldsHelp msgs item _ =
    [ F.simpleTextField
        { getValue = \n -> n
        , item = item
        , onInput = msgs.form << UpdateGroupName
        }
        |> F.Field meta.group_name
        |> F.FormField
    ]
