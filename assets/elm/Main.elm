module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as A
import Json.Decode as Decode
import Messages exposing (Msg(UrlChange))
import Models exposing (Model, decodeFlags, initialModel)
import Navigation
import Route exposing (loc2Page)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main : Program Decode.Value (Result String Model) Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = viewResult
        , update = updateResult
        , subscriptions = subscriptionsResult
        }


init : Decode.Value -> Navigation.Location -> ( Result String Model, Cmd Msg )
init flagsVal location =
    let
        flags =
            Decode.decodeValue decodeFlags flagsVal

        page =
            Result.map (.settings >> loc2Page location >> Tuple.first) flags

        model =
            Result.map2 (.settings >> initialModel) flags page
    in
    updateResult (UrlChange location) model


viewResult : Result String Model -> Html Msg
viewResult result =
    case result of
        Ok model ->
            view model

        Err error ->
            viewError error


updateResult : Msg -> Result String Model -> ( Result String Model, Cmd Msg )
updateResult msg result =
    case result of
        Ok model ->
            let
                ( newModel, newCmd ) =
                    update msg model
            in
            ( Ok newModel, newCmd )

        Err _ ->
            ( result, Cmd.none )


subscriptionsResult : Result String Model -> Sub Msg
subscriptionsResult result =
    case result of
        Ok model ->
            subscriptions model

        Err _ ->
            Sub.none


viewError : String -> Html Msg
viewError err =
    Html.div
        [ A.style
            [ ( "width", "100vw" )
            , ( "height", "100vh" )
            , ( "background", "#5a589b" )
            , ( "color", "#fff" )
            , ( "text-align", "center" )
            , ( "padding-top", "10rem" )
            ]
        ]
        [ Html.h1 [] [ Html.text "Something broke there, please try reloading the page..." ]
        , Html.p [ A.style [ ( "padding-top", "10rem" ) ] ] [ Html.text <| "Detailed error: " ++ err ]
        ]
