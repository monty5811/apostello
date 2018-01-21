module Pages.KeyRespTable exposing (Msg, update, view)

import Data exposing (SmsInbound)
import DjangoSend exposing (CSRFToken, post)
import FilteringTable as FT
import Helpers exposing (..)
import Html exposing (Html, br, button, div, i, input, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Encode as Encode
import RemoteList as RL
import Urls


-- Update


type Msg
    = ArchiveAllButtonClick String
    | ArchiveAllCheckBoxClick
    | ReceiveArchiveAllResp (Result Http.Error Bool)


type alias UpdateProps a =
    { csrftoken : CSRFToken
    , keyRespModel : Bool
    , isArchive : Bool
    , keyword : String
    , store : { a | inboundSms : RL.RemoteList SmsInbound }
    , optArchiveMatchingSms : String -> { a | inboundSms : RL.RemoteList SmsInbound } -> { a | inboundSms : RL.RemoteList SmsInbound }
    }


update : Msg -> UpdateProps a -> ( Bool, Bool, String, { a | inboundSms : RL.RemoteList SmsInbound }, List (Cmd Msg) )
update msg props =
    case msg of
        ArchiveAllCheckBoxClick ->
            ( not props.keyRespModel, props.isArchive, props.keyword, props.store, [] )

        ArchiveAllButtonClick k ->
            ( False, props.isArchive, k, props.optArchiveMatchingSms props.keyword props.store, [ archiveAll props.csrftoken k ] )

        ReceiveArchiveAllResp _ ->
            ( props.keyRespModel, props.isArchive, props.keyword, props.store, [] )


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


view : Props msg -> Bool -> FT.Model -> RL.RemoteList SmsInbound -> Bool -> String -> Html msg
view props viewingArchive tableModel sms ticked keyword =
    div []
        [ FT.defaultTable { top = props.tableMsg } tableHead tableModel (smsRow props) sms
        , br [] []
        , archiveAllForm props viewingArchive ticked keyword
        ]


tableHead : Html msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "From" ]
            , th [] [ text "Time Received" ]
            , th [] [ text "Message" ]
            , th [] [ text "Requires Action?" ]
            , th [ A.class "hide-sm-down" ] []
            ]
        ]


archiveAllForm : Props msg -> Bool -> Bool -> String -> Html msg
archiveAllForm props viewingArchive ticked k =
    case viewingArchive of
        True ->
            text ""

        False ->
            Html.form [ E.onSubmit (props.form <| ArchiveAllButtonClick k) ]
                [ div [ A.class "input-field" ]
                    [ Html.label []
                        [ input
                            [ A.id "id_tick_to_archive_all_responses"
                            , A.name "tick_to_archive_all_responses"
                            , A.attribute "required" ""
                            , A.type_ "checkbox"
                            , A.checked ticked
                            , E.onClick (props.form ArchiveAllCheckBoxClick)
                            ]
                            []
                        , text " Tick to archive all responses"
                        ]
                    ]
                , archiveAllButton ticked
                ]


archiveAllButton : Bool -> Html msg
archiveAllButton ticked =
    case ticked of
        True ->
            button [ A.class "button button-danger", A.id "archiveAllSmsButton" ] [ text "Archive all!" ]

        False ->
            button [ A.class "button button-danger", A.disabled True ] [ text "Archive all!" ]


smsRow : Props msg -> SmsInbound -> ( String, Html msg )
smsRow props sms =
    ( toString sms.pk
    , tr []
        [ recipientCell props sms
        , td [] [ text (formatDate sms.time_received) ]
        , td [] [ text sms.content ]
        , td [] [ dealtWithButton props sms ]
        , archiveCell sms.is_archived (props.toggleInboundSmsArchive sms.is_archived sms.pk)
        ]
    )


recipientCell : Props msg -> SmsInbound -> Html msg
recipientCell props sms =
    td []
        [ props.pkToReplyLink sms
        , props.pkToContactLink sms
        ]


dealtWithButton : Props msg -> SmsInbound -> Html msg
dealtWithButton props sms =
    case sms.dealt_with of
        True ->
            button
                [ A.class "button button-success"
                , onClick (props.toggleDealtWith sms.dealt_with sms.pk)
                , A.id "unDealWithButton"
                ]
                [ i [ A.class "fa fa-check" ] [], text " Dealt With" ]

        False ->
            button
                [ A.class "button button-warning"
                , onClick (props.toggleDealtWith sms.dealt_with sms.pk)
                , A.id "dealWithButton"
                ]
                [ i [ A.class "fa fa-exclamation" ] [], text " Requires Action" ]
