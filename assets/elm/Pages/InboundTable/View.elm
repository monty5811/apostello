module Pages.InboundTable.View exposing (view)

import Data.SmsInbound exposing (SmsInbound)
import Data.Store as Store
import FilteringTable exposing (uiTable)
import Helpers exposing (formatDate)
import Html exposing (Html, a, b, i, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(InboundTableMsg))
import Pages exposing (Page(ContactForm, KeywordForm), initSendAdhoc)
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Pages.InboundTable.Messages exposing (InboundTableMsg(..))
import Pages.KeywordForm.Model exposing (initialKeywordFormModel)
import Regex
import Route exposing (spaLink)


-- Main view


view : Regex.Regex -> Store.RemoteList SmsInbound -> Html Msg
view filterRegex sms =
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
    uiTable head filterRegex smsRow sms


smsRow : SmsInbound -> Html Msg
smsRow sms =
    tr [ A.style [ ( "backgroundColor", sms.matched_colour ) ] ]
        [ recipientCell sms
        , keywordCell sms
        , td [] [ text sms.content ]
        , td [ A.class "collapsing" ] [ text (formatDate sms.time_received) ]
        , reprocessCell sms
        ]


recipientCell : SmsInbound -> Html Msg
recipientCell sms =
    let
        replyPage =
            initSendAdhoc Nothing <| Maybe.map List.singleton sms.sender_pk

        contactPage =
            ContactForm initialContactFormModel <| sms.sender_pk
    in
    td []
        [ spaLink a [] [ i [ A.class "violet reply link icon" ] [] ] replyPage
        , spaLink a [ A.style [ ( "color", "#212121" ) ] ] [ text sms.sender_name ] contactPage
        ]


keywordCell : SmsInbound -> Html Msg
keywordCell sms =
    case sms.matched_keyword of
        "#" ->
            td [] [ b [] [ text sms.matched_keyword ] ]

        _ ->
            td []
                [ b []
                    [ spaLink a
                        [ A.style [ ( "color", "#212121" ) ] ]
                        [ text sms.matched_keyword ]
                        (KeywordForm initialKeywordFormModel <| Just sms.matched_keyword)
                    ]
                ]


reprocessCell : SmsInbound -> Html Msg
reprocessCell sms =
    td [ A.class "collapsing" ]
        [ a [ A.class "ui tiny blue button", E.onClick (InboundTableMsg (ReprocessSms sms.pk)) ] [ text "Reprocess" ]
        ]
