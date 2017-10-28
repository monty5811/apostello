module Pages.FirstRun exposing (Model, Msg, decodeFirstRunResp, initialModel, update, view)

import DjangoSend exposing (CSRFToken, post)
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
        [ Html.div [ A.class "segment" ]
            [ Html.h3 [] [ Html.text "Create Admin User" ]
            , Html.form [ onSubmit CreateAdminUser ]
                [ formMsg model.adminFormStatus adminSuccessMsg
                , Html.div [ A.class "input-field" ]
                    [ Html.label [] [ Html.text "Admin Email" ]
                    , Html.input
                        [ A.type_ "email"
                        , A.name "email"
                        , A.placeholder "you@example.com"
                        , A.id "admin_email"
                        , onInput UpdateAdminEmailField
                        ]
                        []
                    ]
                , Html.div [ A.class "two-column" ]
                    [ Html.div [ A.class "input-field" ]
                        [ Html.label [] [ Html.text "Password" ]
                        , Html.input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass1"
                            , onInput UpdateAdminPass1Field
                            ]
                            []
                        ]
                    , Html.div [ A.class "input-field" ]
                        [ Html.label [] [ Html.text "Password Again" ]
                        , Html.input
                            [ A.type_ "password"
                            , A.name "password"
                            , A.id "admin_pass2"
                            , onInput UpdateAdminPass2Field
                            ]
                            []
                        ]
                    ]
                , Html.button [ A.class "button", A.id "create_admin_button" ]
                    [ Html.text "Create" ]
                ]
            ]
        ]


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
            Html.div [ A.class "alert alert-danger" ]
                [ Html.h4 [] [ Html.text "Uh oh, something went wrong!" ]
                , Html.p [] [ Html.text "Check your settings and try again." ]
                , Html.p [] [ Html.text "Error:" ]
                , Html.pre [] [ Html.text e ]
                ]


adminSuccessMsg : Html Msg
adminSuccessMsg =
    Html.div [ A.class "alert alert-success" ]
        [ Html.h4 [] [ Html.text "Admin User Created" ]
        , Html.p [] [ Html.text "Refresh this page and you will be able to login" ]
        ]
