module Pages.KeyRespTable exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (SmsInbound)
import DjangoSend exposing (CSRFToken, post)
import FilteringTable as FT
import Helpers exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Encode as Encode
import RemoteList as RL
import Urls


type alias Model =
    { tableModel : FT.Model
    , checkboxTicked : Bool
    }


initialModel : Model
initialModel =
    { tableModel = FT.initialModel
    , checkboxTicked = False
    }



-- Update


type Msg
    = ArchiveAllButtonClick String
    | ArchiveAllCheckBoxClick
    | ReceiveArchiveAllResp (Result Http.Error Bool)
    | TableMsg FT.Msg


type alias UpdateProps a =
    { csrftoken : CSRFToken
    , isArchive : Bool
    , keyword : String
    , store : { a | inboundSms : RL.RemoteList SmsInbound }
    , optArchiveMatchingSms : String -> { a | inboundSms : RL.RemoteList SmsInbound } -> { a | inboundSms : RL.RemoteList SmsInbound }
    }


type alias UpdateReturn a =
    { model : Model
    , isArchive : Bool
    , keyword : String
    , store : { a | inboundSms : RL.RemoteList SmsInbound }
    , cmds : List (Cmd Msg)
    }


update : UpdateProps a -> Msg -> Model -> UpdateReturn a
update props msg model =
    case msg of
        ArchiveAllCheckBoxClick ->
            UpdateReturn
                { model | checkboxTicked = not model.checkboxTicked }
                props.isArchive
                props.keyword
                props.store
                []

        ArchiveAllButtonClick k ->
            UpdateReturn
                { model | checkboxTicked = False }
                props.isArchive
                k
                (props.optArchiveMatchingSms props.keyword props.store)
                [ archiveAll props.csrftoken k ]

        ReceiveArchiveAllResp _ ->
            UpdateReturn
                model
                props.isArchive
                props.keyword
                props.store
                []

        TableMsg tableMsg ->
            UpdateReturn
                { model | tableModel = FT.update tableMsg model.tableModel }
                props.isArchive
                props.keyword
                props.store
                []


archiveAll : CSRFToken -> String -> Cmd Msg
archiveAll csrf keyword =
    let
        body =
            [ ( "tick_to_archive_all_responses", Encode.bool True ) ]
    in
    post csrf (Urls.api_act_keyword_archive_all_responses keyword) body decodeAlwaysTrue
        |> Http.send ReceiveArchiveAllResp



-- View


type alias Props msg =
    { form : Msg -> msg
    , tableMsg : FT.Msg -> msg
    , toggleDealtWith : Bool -> Int -> msg
    , pkToReplyLink : SmsInbound -> Html msg
    , pkToContactLink : SmsInbound -> Html msg
    , toggleInboundSmsArchive : Bool -> Int -> msg
    }


view : Props msg -> Bool -> RL.RemoteList SmsInbound -> String -> Model -> Html msg
view props viewingArchive sms keyword { tableModel, checkboxTicked } =
    Html.div []
        [ FT.defaultTable { top = props.tableMsg } tableHead tableModel (smsRow props) sms
        , Html.br [] []
        , archiveAllForm props viewingArchive checkboxTicked keyword
        ]


tableHead : FT.Head
tableHead =
    FT.Head
        [ "From"
        , "Time Received"
        , "Message"
        , "Requires Action?"
        , ""
        ]


archiveAllForm : Props msg -> Bool -> Bool -> String -> Html msg
archiveAllForm props viewingArchive ticked k =
    case viewingArchive of
        True ->
            Html.text ""

        False ->
            Html.form [ E.onSubmit (props.form <| ArchiveAllButtonClick k) ]
                [ Html.div []
                    [ Html.label [ Css.label ]
                        [ Html.input
                            [ A.id "id_tick_to_archive_all_responses"
                            , A.name "tick_to_archive_all_responses"
                            , A.attribute "required" ""
                            , A.type_ "checkbox"
                            , A.checked ticked
                            , E.onClick (props.form ArchiveAllCheckBoxClick)
                            ]
                            []
                        , Html.text " Tick to archive all responses"
                        ]
                    ]
                , archiveAllButton ticked
                ]


archiveAllButton : Bool -> Html msg
archiveAllButton ticked =
    case ticked of
        True ->
            Html.button [ A.id "archiveAllSmsButton", Css.btn, Css.btn_purple ] [ Html.text "Archive all!" ]

        False ->
            Html.button [ A.disabled True, Css.btn, Css.btn_grey ] [ Html.text "Archive all!" ]


smsRow : Props msg -> SmsInbound -> FT.Row msg
smsRow props sms =
    FT.Row
        []
        [ FT.Cell [] <| recipientCell props sms
        , FT.Cell [] [ Html.text <| formatDate sms.time_received ]
        , FT.Cell [] [ Html.text sms.content ]
        , FT.Cell [ Css.collapsing ] [ dealtWithButton props sms ]
        , FT.Cell [ Css.collapsing ] [ archiveCell sms.is_archived (props.toggleInboundSmsArchive sms.is_archived sms.pk) ]
        ]
        (toString sms.pk)


recipientCell : Props msg -> SmsInbound -> List (Html msg)
recipientCell props sms =
    [ props.pkToReplyLink sms
    , props.pkToContactLink sms
    ]


dealtWithButton : Props msg -> SmsInbound -> Html msg
dealtWithButton props sms =
    case sms.dealt_with of
        True ->
            Html.button
                [ onClick (props.toggleDealtWith sms.dealt_with sms.pk)
                , A.id "unDealWithButton"
                , Css.pill
                , Css.pill_green
                ]
                [ Html.i [ A.class "fa fa-check" ] [], Html.text " Dealt With" ]

        False ->
            Html.button
                [ onClick (props.toggleDealtWith sms.dealt_with sms.pk)
                , A.id "dealWithButton"
                , Css.pill
                , Css.pill_orange
                ]
                [ Html.i [ A.class "fa fa-exclamation" ] [], Html.text " Requires Action" ]
