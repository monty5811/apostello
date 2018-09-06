module Pages.FirstRun exposing (Model, Msg, decodeFirstRunResp, initialModel, update, view)

import Css
import DjangoSend exposing (CSRFToken, post)
import Form as F
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode


type alias FirstRunResp =
    { status : String
    , error : String
    }


type FirstRunFormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String


decodeFirstRunResp : Decode.Decoder FirstRunResp
decodeFirstRunResp =
    decode FirstRunResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""


type alias Model =
    { adminEmail : String
    , adminPass1 : String
    , adminPass2 : String
    , adminFormStatus : FirstRunFormStatus
    }


initialModel : Model
initialModel =
    { adminEmail = ""
    , adminPass1 = ""
    , adminPass2 = ""
    , adminFormStatus = NoAction
    }



-- Update


type Msg
    = UpdateAdminEmailField String
    | UpdateAdminPass1Field String
    | UpdateAdminPass2Field String
    | CreateAdminUser
    | ReceiveCreateAdminUser (Result Http.Error FirstRunResp)


update : CSRFToken -> Msg -> Model -> ( Model, List (Cmd Msg) )
update csrf msg model =
    case msg of
        UpdateAdminEmailField text ->
            ( { model | adminEmail = text }, [] )

        UpdateAdminPass1Field text ->
            ( { model | adminPass1 = text }, [] )

        UpdateAdminPass2Field text ->
            ( { model | adminPass2 = text }, [] )

        CreateAdminUser ->
            case model.adminPass1 == model.adminPass2 of
                True ->
                    ( { model | adminFormStatus = InProgress }, [ createAdminUser csrf model ] )

                False ->
                    ( { model | adminFormStatus = Failed "Passwords do not match" }, [] )

        ReceiveCreateAdminUser (Ok _) ->
            ( { model | adminFormStatus = Success }, [] )

        ReceiveCreateAdminUser (Err e) ->
            ( { model | adminFormStatus = Failed (pullOutError e) }, [] )


pullOutError : Http.Error -> String
pullOutError e =
    case e of
        Http.BadUrl _ ->
            "Bad url"

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus r ->
            r.body
                |> Decode.decodeString decodeFirstRunResp
                |> Result.withDefault { status = "", error = r.body }
                |> .error

        Http.BadPayload msg _ ->
            msg


createAdminUser : CSRFToken -> Model -> Cmd Msg
createAdminUser csrf model =
    let
        body =
            [ ( "email_", Encode.string model.adminEmail )
            , ( "pass_", Encode.string model.adminPass1 )
            ]
    in
    post csrf "/config/create_admin_user/" body decodeFirstRunResp
        |> Http.send ReceiveCreateAdminUser



-- View


view : Model -> Html Msg
view model =
    Html.div [] [ createAdminView model ]


createAdminView : Model -> Html Msg
createAdminView model =
    Html.div [ A.id "create_admin_user" ]
        [ Html.div []
            [ Html.h3 [] [ Html.text "Create Admin User" ]
            , Html.form [ onSubmit CreateAdminUser ]
                [ formMsg model.adminFormStatus adminSuccessMsg
                , Html.div []
                    [ F.label <| makeMeta "admin_email" "Admin Email"
                    , Html.input
                        [ A.type_ "email"
                        , A.name "email"
                        , A.placeholder "you@example.com"
                        , A.id "admin_email"
                        , onInput UpdateAdminEmailField
                        , Css.formInput
                        ]
                        []
                    ]
                , Html.div []
                    [ Html.div []
                        [ F.label <| makeMeta "admin_pass1" "Password"
                        , Html.input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass1"
                            , onInput UpdateAdminPass1Field
                            , Css.formInput
                            ]
                            []
                        ]
                    , Html.div []
                        [ F.label <| makeMeta "admin_pass2" "Password Again"
                        , Html.input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass2"
                            , onInput UpdateAdminPass2Field
                            , Css.formInput
                            ]
                            []
                        ]
                    ]
                , Html.button
                    [ A.id "create_admin_button"
                    , Css.btn
                    , Css.btn_purple
                    , Css.mt_4
                    ]
                    [ Html.text "Create" ]
                ]
            ]
        ]


makeMeta : String -> String -> { id : String, label : String, required : Bool, name : String, help : Maybe String }
makeMeta id label =
    { id = id
    , label = label
    , required = True
    , name = label
    , help = Just label
    }


formMsg : FirstRunFormStatus -> Html Msg -> Html Msg
formMsg status successDiv =
    case status of
        NoAction ->
            Html.text ""

        InProgress ->
            Html.text ""

        Success ->
            successDiv

        Failed e ->
            Html.div []
                [ Html.h4 [] [ Html.text "Uh oh, something went wrong!" ]
                , Html.p [] [ Html.text "Check your settings and try again." ]
                , Html.p [] [ Html.text "Error:" ]
                , Html.pre [] [ Html.text e ]
                ]


adminSuccessMsg : Html Msg
adminSuccessMsg =
    Html.div
        [ Css.mb_2
        , A.class <| "alert alert-success"
        , A.attribute "role" "alert"
        ]
        [ Html.h4 [] [ Html.text "Admin User Created" ]
        , Html.p [] [ Html.text "Refresh this page and you will be able to login" ]
        ]
