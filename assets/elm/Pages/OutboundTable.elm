module Pages.OutboundTable exposing (view)

import Data exposing (SmsOutbound)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html, a, td, text, th, thead, tr)
import Html.Attributes as A
import Messages exposing (Msg)
import Pages exposing (Page(ContactForm))
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (spaLink)


-- Main view


view : FT.Model -> RL.RemoteList SmsOutbound -> Html Msg
view tableModel sms =
    FT.defaultTable tableHead tableModel smsRow sms


tableHead : Html Msg
tableHead =
    thead []
        [ tr []
            [ th [] [ text "To" ]
            , th [] [ text "Message" ]
            , th [] [ text "Sent" ]
            ]
        ]


smsRow : SmsOutbound -> ( String, Html Msg )
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
    ( toString sms.pk
    , tr []
        [ td []
            [ spaLink a [ A.style [ "color" => "var(--color-black)" ] ] [ text recipient.full_name ] contactPage
            ]
        , td [] [ text sms.content ]
        , td [] [ text (formatDate sms.time_sent) ]
        ]
    )
