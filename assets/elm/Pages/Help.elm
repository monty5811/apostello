module Pages.Help exposing (view)

import Css
import Html exposing (Html)
import Html.Attributes as A


view : Html msg
view =
    Html.div
        [ Css.mt_4 ]
        [ Html.h3 [ A.id "faqs" ] [ Html.text "FAQs" ]
        , qA "How do I “mail merge” my messages? "
            [ Html.text "Any occurrence of "
            , Html.code [] [ Html.text "%name%" ]
            , Html.text " in any outgoing message will be converted to the first name of each recipient of the message. This also applies to automatic replies sent out by the system."
            ]
        , qA "Can I send a message to a group without visiting this site?"
            [ Html.text "No, you must come here to send a message. However the site should work fine on your phone or tablet." ]
        , qA "What’s a keyword?"
            [ Html.text "All incoming messages are expected to start with a keyword (maximum length, 12) followed by a space. This is to allow easy collection, grouping, tracking and export of incoming messages and to make it easy to use this service for things like event sign ups or polls and surveys." ]
        , qA
            "I thought there was a particular keyword, but I can’t see it? "
            [ Html.text "You either don’t have access, or someone deleted it. You can request access from the Production Team, who can also recovery deleted keywords." ]
        , qA
            "How do I get rid of matched keyword responses?"
            [ Html.text "Click "
            , Html.code [] [ Html.text "Archive" ]
            , Html.text " to remove a single message, or "
            , Html.code [] [ Html.text "Archive all now!" ]
            , Html.text "to remove all the messages for a keyword."
            ]
        , qA
            "What happened to all my keyword responses? "
            [ Html.text "Someone probably archived them. You can view them by clicking on the "
            , Html.code [] [ Html.text "Archived Replies" ]
            , Html.text "button when viewing a keyword."
            ]
        , qA
            "How can I stop getting messages? "
            [ Html.text "Reply to any message with "
            , Html.code [] [ Html.text "stop" ]
            , Html.text "and you will be unsubscribed from all future messages. You will need to send "
            , Html.code [] [ Html.text "start" ]
            , Html.text "to the same number to receive messages again. We cannot reactivate you - the unsubscribing is handled by Twilio and will stop you from receiving any messages from us. This is not a good idea if you want to sign up for things using this service."
            ]
        ]


qA : String -> List (Html msg) -> Html msg
qA q a =
    Html.div []
        [ Html.p [ Css.mt_4, Css.mb_1 ] [ Html.text <| "Q. " ++ q ]
        , Html.div [ Css.ml_2, Css.pl_2, Css.border_l_2 ] a
        ]
