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
                [ Html.button [ A.class "ui primary button", E.onClick <| ApiSetupMsg Get ] [ Html.text "Show Key" ]
                ]

        Just apiKey ->
            Html.div []
                [ Html.p []
                    [ Html.text "For more details and help, please read the "
                    , Html.a [ A.href "https://apostello.readthedocs.io/en/latest/api.html" ] [ Html.text "docs" ]
                    , Html.text "."
                    , Html.div [ A.class "ui segments" ]
                        [ Html.div [ A.class "ui segment" ]
                            [ Html.p [] [ Html.text "API Token" ]
                            , Html.div [ A.class "ui secondary segement" ]
                                [ Html.pre [] [ Html.text apiKey ]
                                ]
                            ]
                        ]
                    , Html.div [ A.class "ui buttons" ]
                        [ Html.button [ A.class "ui green button", E.onClick <| ApiSetupMsg Generate ] [ Html.text "(Re)Generate Token" ]
                        , Html.button [ A.class "ui red button", E.onClick <| ApiSetupMsg Delete ] [ Html.text "Delete Token" ]
                        ]
                    ]
                ]
