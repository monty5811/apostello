module Pages.DeletePanel exposing (Model, Msg, initialModel, update, view)

import Css
import Data exposing (SmsInbound, SmsOutbound)
import DjangoSend exposing (CSRFToken, post)
import Helpers exposing (toggleSelectedPk)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL
import Urls



-- Model


type alias Model =
    { selectedInbound : List Int
    , selectedOutbound : List Int
    , step : Step
    }


type Step
    = SelectMessages
    | ConfirmationMessage
    | TypeToConfirm String
    | Waiting
    | FinishedSuccess
    | FinishedError


initialModel : Model
initialModel =
    { selectedInbound = []
    , selectedOutbound = []
    , step = SelectMessages
    }



-- Update


type Msg
    = ToggleInbound Int
    | ToggleOutbound Int
    | DeleteClicked
    | ConfirmClicked
    | Typing String
    | FinalDeleteClicked
    | ReceiveResponse (Result Http.Error Bool)


type alias UpdateProps =
    { csrftoken : CSRFToken
    }


update : UpdateProps -> Msg -> Model -> ( Model, Cmd Msg )
update props msg model =
    case msg of
        ToggleInbound pk ->
            ( { model | selectedInbound = toggleSelectedPk pk model.selectedInbound }, Cmd.none )

        ToggleOutbound pk ->
            ( { model | selectedOutbound = toggleSelectedPk pk model.selectedOutbound }, Cmd.none )

        DeleteClicked ->
            ( { model | step = ConfirmationMessage }, Cmd.none )

        ConfirmClicked ->
            ( { model | step = TypeToConfirm "" }, Cmd.none )

        Typing str ->
            ( { model | step = TypeToConfirm str }, Cmd.none )

        FinalDeleteClicked ->
            case model.step of
                TypeToConfirm confirmString ->
                    if confirmTypedOk confirmString then
                        ( { model | step = Waiting }
                        , deleteCmd props.csrftoken
                            model.selectedInbound
                            model.selectedOutbound
                        )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReceiveResponse (Ok _) ->
            ( { model | step = FinishedSuccess }, Cmd.none )

        ReceiveResponse (Err _) ->
            ( { model | step = FinishedError }, Cmd.none )


deleteCmd : CSRFToken -> List Int -> List Int -> Cmd Msg
deleteCmd csrf incomingPks outgoingPks =
    post csrf
        Urls.api_act_permanent_delete
        [ ( "incoming_pks", Encode.list <| List.map Encode.int incomingPks )
        , ( "outgoing_pks", Encode.list <| List.map Encode.int outgoingPks )
        ]
        (Decode.succeed True)
        |> Http.send ReceiveResponse


confirmTypedOk : String -> Bool
confirmTypedOk str =
    str == msgToType


msgToType : String
msgToType =
    "I understand this cannot be undone"


type alias ViewProps =
    { inboundSms : RL.RemoteList SmsInbound
    , outboundSms : RL.RemoteList SmsOutbound
    }


view : ViewProps -> Model -> Html Msg
view props model =
    Html.div [ Css.max_w_md, Css.mx_auto ]
        [ case model.step of
            SelectMessages ->
                Html.div []
                    [ Html.p [ Css.mb_2 ] [ Html.text "Messages are stored in Twilio forever." ]
                    , Html.p [ Css.mb_2 ] [ Html.text "But you may want to delete them for a variety of reasons (e.g. GDPR compliance). This tool let's you select as many messages you like and delete them from apostello and from Twilio" ]
                    , Html.p [ Css.alert, Css.alert_danger, Css.mb_2 ] [ Html.text "If you delete any messages using this tool, it cannot be undone - please be careful with this." ]
                    , Html.div [ Css.my_2 ] [ deleteButton model ]
                    , Html.div [ Css.flex ]
                        [ inboundMessages props.inboundSms model.selectedInbound
                        , outboundMessages props.outboundSms model.selectedOutbound
                        ]
                    ]

            ConfirmationMessage ->
                confirmationMessage

            TypeToConfirm str ->
                typeToConfirm str

            Waiting ->
                loader

            FinishedSuccess ->
                finishedOk

            FinishedError ->
                finishedErr
        ]


inboundMessages : RL.RemoteList SmsInbound -> List Int -> Html Msg
inboundMessages sms pks =
    Html.div [ Css.mx_2, Css.flex_1 ]
        [ Html.h3 [] [ Html.text "Incoming Messages" ]
        , Html.div [] <| rlView <| RL.map (incomingMsg pks) sms
        ]


outboundMessages : RL.RemoteList SmsOutbound -> List Int -> Html Msg
outboundMessages sms pks =
    Html.div [ Css.mx_2, Css.flex_1 ]
        [ Html.h3 [] [ Html.text "Outgoing Messages" ]
        , Html.div [] <| rlView <| RL.map (outgoingMsg pks) sms
        ]


rlView : RL.RemoteList (Html msg) -> List (Html msg)
rlView nodesRL =
    case nodesRL of
        RL.WaitingForFirstResp _ ->
            [ loader ]

        _ ->
            RL.toList nodesRL


incomingMsg : List Int -> SmsInbound -> Html Msg
incomingMsg selectedPks sms =
    let
        selected =
            List.member sms.pk selectedPks
    in
    Html.div
        [ A.id <| "incoming_sms" ++ toString sms.pk
        , Css.border_b_2
        , Css.select_none
        , Css.cursor_pointer
        , if selected then
            Css.bg_red

          else
            Css.bg_grey
        , Css.px_2
        ]
        [ Html.div [ E.onClick (ToggleInbound sms.pk) ]
            [ Html.text sms.content ]
        ]


outgoingMsg : List Int -> SmsOutbound -> Html Msg
outgoingMsg selectedPks sms =
    let
        selected =
            List.member sms.pk selectedPks
    in
    Html.div
        [ A.id <| "outgoing_sms" ++ toString sms.pk
        , Css.border_b_2
        , Css.select_none
        , Css.cursor_pointer
        , if selected then
            Css.bg_red

          else
            Css.bg_grey
        , Css.px_2
        ]
        [ Html.div [ E.onClick (ToggleOutbound sms.pk) ]
            [ Html.text sms.content ]
        ]


deleteButton : Model -> Html Msg
deleteButton { selectedOutbound, selectedInbound } =
    if List.all List.isEmpty [ selectedOutbound, selectedInbound ] then
        Html.button [ A.id "deleteButton", Css.w_full, Css.btn, Css.btn_grey ] [ Html.text "Delete Messages!" ]

    else
        Html.button [ A.id "deleteButton", Css.w_full, Css.btn, Css.btn_red, E.onClick DeleteClicked ] [ Html.text "Delete Messages!" ]


confirmationMessage : Html Msg
confirmationMessage =
    Html.div []
        [ Html.p [ Css.mb_2 ] [ Html.text "Are you sure you want to delete these messages? They will be removed from apostello and also deleted from Twilio. There is no way to recover these messages. They will be gone forever." ]
        , Html.button
            [ Css.w_full
            , Css.btn
            , Css.btn_red
            , E.onClick ConfirmClicked
            , A.id "confirmButton"
            ]
            [ Html.text "Yes, I'm Sure" ]
        ]


typeToConfirm : String -> Html Msg
typeToConfirm str =
    Html.div []
        [ Html.p [ Css.mb_2 ]
            [ Html.text <|
                "To confirm the deletion, please type \""
                    ++ msgToType
                    ++ "\" into the box and click the button."
            ]
        , Html.div [ Css.mb_2 ]
            [ Html.label [ Css.label ]
                [ Html.text <|
                    "Type \""
                        ++ msgToType
                        ++ "\" to proceed."
                ]
            , Html.input
                [ A.type_ "email"
                , A.name "confirm-delete"
                , A.id "confirmDeleteInput"
                , E.onInput Typing
                , Css.formInput
                ]
                []
            ]
        , if confirmTypedOk str then
            Html.button
                [ Css.btn
                , Css.btn_red
                , E.onClick FinalDeleteClicked
                , A.id "finalConfirmButton"
                ]
                [ Html.text "Delete the messages" ]

          else
            Html.button
                [ Css.btn
                , Css.btn_grey
                , A.id "finalConfirmButton"
                ]
                [ Html.text "Delete the messages" ]
        ]


finishedOk : Html msg
finishedOk =
    Html.div [ Css.alert, Css.alert_success ]
        [ Html.p [] [ Html.text "Messages successfully queued for deletion." ]
        ]


finishedErr : Html msg
finishedErr =
    Html.div [ Css.alert, Css.alert_danger ]
        [ Html.p []
            [ Html.text "Uh oh. Something went wrong there."
            , Html.p [] [ Html.text "Please wait a couple of minutes, refresh the page and try again." ]
            ]
        ]
