module Pages.OutboundTable exposing (view)

import Data.SmsOutbound exposing (SmsOutbound)
import Data.Store as Store
import FilteringTable.Model as FTM
import FilteringTable.View exposing (uiTable)
import Helpers exposing (formatDate)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes as A
import Messages exposing (Msg)
import Pages exposing (Page(ContactForm))
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Route exposing (spaLink)


-- Main view


view : FTM.Model -> Store.RemoteList SmsOutbound -> Html Msg
view tableModel sms =
    uiTable tableHead tableModel smsRow sms


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "To" ]
            , th [] [ text "Message" ]
            , th [] [ text "Sent" ]
            ]
        ]


smsRow : SmsOutbound -> Html Msg
smsRow sms =
    let
        recipient =
            case sms.recipient of
                Just r ->
                    r

                Nothing ->
                    { full_name = "", pk = 0 }

        contactPage =
            ContactForm initialContactFormModel <| Just recipient.pk
    in
    tr []
        [ td [ A.class "collapsing" ]
            [ spaLink a [ A.style [ ( "color", "#212121" ) ] ] [ text recipient.full_name ] contactPage
            ]
        , td [] [ text sms.content ]
        , td [ A.class "collapsing" ] [ text (formatDate sms.time_sent) ]
        ]
