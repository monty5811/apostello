module Pages.RecipientTable exposing (view)

import Data exposing (Recipient)
import FilteringTable as FT
import Helpers exposing (archiveCell, formatDate)
import Html exposing (Html, div, td, text, th, thead, tr)
import Html.Attributes as A
import RemoteList as RL
import Rocket exposing ((=>))


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , tableModel : FT.Model
    , recipients : RL.RemoteList Recipient
    , toggleRecipientArchive : Bool -> Int -> msg
    , contactLink : Recipient -> Html msg
    }


view : Props msg -> Html msg
view props =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "Last Message" ]
                    , th [] [ text "Received" ]
                    , th [ A.class "hide-sm-down" ] []
                    ]
                ]
    in
    FT.defaultTable { top = props.tableMsg } head props.tableModel (recipientRow props) props.recipients


recipientRow : Props msg -> Recipient -> ( String, Html msg )
recipientRow props recipient =
    let
        style =
            case recipient.is_blocking of
                True ->
                    [ "background" => "var(--color-red)" ]

                False ->
                    []

        timeReceived =
            Maybe.andThen .time_received recipient.last_sms

        content =
            case recipient.last_sms of
                Just sms ->
                    sms.content

                Nothing ->
                    ""
    in
    ( toString recipient.pk
    , tr [ A.style style ]
        [ td []
            [ props.contactLink recipient
            , doNotReplyIndicator recipient.do_not_reply
            ]
        , td [] [ text content ]
        , td [] [ text <| formatDate timeReceived ]
        , archiveCell recipient.is_archived (props.toggleRecipientArchive recipient.is_archived recipient.pk)
        ]
    )


doNotReplyIndicator : Bool -> Html msg
doNotReplyIndicator reply =
    case reply of
        True ->
            div [ A.class "badge badge-danger" ] [ text "No Reply" ]

        False ->
            text ""
