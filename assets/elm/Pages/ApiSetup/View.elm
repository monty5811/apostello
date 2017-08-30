module Pages.ApiSetup.View exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(ApiSetupMsg))
import Pages.ApiSetup.Messages exposing (ApiSetupMsg(..))


view : Maybe String -> Html Msg
view maybeApiKey =
    case maybeApiKey of
        Nothing ->
            Html.div []
                [ Html.button [ A.class "button", E.onClick <| ApiSetupMsg Get, A.id "showKeyButton" ] [ Html.text "Show Key" ]
                ]

        Just apiKey ->
            Html.div []
                [ Html.p []
                    [ Html.text "For more details and help, please read the "
                    , Html.a [ A.href "https://apostello.readthedocs.io/en/latest/api.html" ] [ Html.text "docs" ]
                    , Html.text "."
                    ]
                , Html.br [] []
                , Html.p [] [ Html.text "API Token" ]
                , Html.pre [] [ Html.text apiKey ]
                , Html.button [ A.class "button button-success", E.onClick <| ApiSetupMsg Generate, A.id "genKeyButton" ] [ Html.text "(Re)Generate Token" ]
                , Html.button [ A.class "button button-danger", E.onClick <| ApiSetupMsg Delete, A.id "delKeyButton" ] [ Html.text "Delete Token" ]
                ]
