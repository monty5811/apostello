module Views.InboundTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, href, style)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Models exposing (..)
import Regex
import Views.FilteringTable exposing (filteringTable)


-- Main view


view : Regex.Regex -> InboundTableModel -> Html Msg
view filterRegex model =
    let
        head =
            thead []
                [ tr []
                    [ th [] [ text "From" ]
                    , th [] [ text "Keyword" ]
                    , th [] [ text "Message" ]
                    , th [] [ text "Time" ]
                    , th [] []
                    ]
                ]
    in
        filteringTable filterRegex smsRow model.sms head "ui table"


smsRow : SmsInbound -> Html Msg
smsRow sms =
    tr [ style [ ( "backgroundColor", sms.matched_colour ) ] ]
        [ recipientCell sms
        , keywordCell sms
        , td [] [ text sms.content ]
        , td [ class "collapsing" ] [ text sms.time_received ]
        , reprocessCell sms
        ]


recipientCell : SmsInbound -> Html Msg
recipientCell sms =
    let
        replyLink =
            case sms.sender_pk of
                Just pk ->
                    "/send/adhoc/?recipient=" ++ (toString pk)

                Nothing ->
                    "#"

        contactLink =
            case sms.sender_url of
                Just url ->
                    url

                Nothing ->
                    "#"
    in
        td []
            [ a [ href replyLink ] [ i [ class "violet reply link icon" ] [] ]
            , a [ href contactLink, style [ ( "color", "#212121" ) ] ] [ text sms.sender_name ]
            ]


keywordCell : SmsInbound -> Html Msg
keywordCell sms =
    case sms.matched_keyword of
        "#" ->
            td [] [ b [] [ text sms.matched_keyword ] ]

        _ ->
            td []
                [ b []
                    [ a [ href sms.matched_link, style [ ( "color", "#212121" ) ] ] [ text sms.matched_keyword ]
                    ]
                ]


reprocessCell : SmsInbound -> Html Msg
reprocessCell sms =
    td [ class "collapsing" ]
        [ a [ class "ui tiny blue button", onClick (InboundTableMsg (ReprocessSms sms.pk)) ] [ text "Reprocess" ]
        ]
