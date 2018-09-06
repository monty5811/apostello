module Pages.Forms.CreateAllGroup exposing (Model, Msg(..), initialModel, update, view)

import DjangoSend
import Form as F exposing (..)
import Html exposing (Html)
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.CreateAllGroup exposing (meta)
import Urls


type alias Model =
    { name : String
    , formStatus : FormStatus
    }


initialModel : Model
initialModel =
    { name = ""
    , formStatus = NoAction
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
                { model | name = name }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postFormCmd
                    props.csrftoken
                    model.name
                )
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


postFormCmd : DjangoSend.CSRFToken -> String -> Cmd Msg
postFormCmd csrf name =
    let
        body =
            [ ( "group_name", Encode.string name ) ]
    in
    DjangoSend.rawPost csrf Urls.api_act_create_all_group body
        |> Http.send ReceiveFormResp



-- View


type alias Messages msg =
    { form : Msg -> msg
    }


view : Messages msg -> Model -> Html msg
view msgs model =
    let
        field =
            simpleTextField (Just model.name) (msgs.form << UpdateGroupName)
                |> Field meta.group_name
                |> FormField

        button =
            submitButton Nothing
    in
    Html.div []
        [ Html.p [] [ Html.text "You can use this form to create a new group that contains all currently active contacts." ]
        , form model.formStatus [ field ] (msgs.form PostForm) button
        ]
