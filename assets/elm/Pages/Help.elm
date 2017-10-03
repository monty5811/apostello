module Pages.Help exposing (view)

import Html exposing (Html, code, div, h3, p, text)
import Html.Attributes exposing (id)


view : Html msg
view =
    div
        []
        [ h3 [ id "faqs" ] [ text "FAQs" ]
        , p [] [ text "Q. How do I “mail merge” my messages? " ]
        , p []
            [ text "A. Any occurrence of "
            , code [] [ text "%name%" ]
            , text "in any outgoing message will be converted to the first name of each recipient of the message. This also applies to automatic replies sent out by the system."
            ]
        , p [] [ text "Q. Can I send a message to a group without visiting this site?" ]
        , p [] [ text "A. No, you must come here to send a message. However the site should work fine on your phone or tablet." ]
        , p [] [ text "Q. What’s a keyword?" ]
        , p [] [ text "A. All incoming messages are expected to start with a keyword (maximum length, 12) followed by a space. This is to allow easy collection, grouping, tracking and export of incoming messages and to make it easy to use this service for things like event sign ups or polls and surveys." ]
        , p [] [ text "Q. I thought there was a particular keyword, but I can’t see it? " ]
        , p [] [ text "A. You either don’t have access, or someone deleted it. You can request access from the Production Team, who can also recovery deleted keywords." ]
        , p [] [ text "Q. How do I get rid of matched keyword responses?" ]
        , p []
            [ text "A. Click"
            , code [] [ text "Archive" ]
            , text "to remove a single message, or "
            , code [] [ text "Archive all now!" ]
            , text "to remove all the messages for a keyword."
            ]
        , p [] [ text "Q. What happened to all my keyword responses? " ]
        , p []
            [ text "A. Someone probably archived them. You can view them by clicking on the "
            , code [] [ text "Archived Replies" ]
            , text "button when viewing a keyword."
            ]
        , p []
            [ text "Q. How can I stop getting messages? " ]
        , p []
            [ text "A. Reply to any message with "
            , code [] [ text "stop" ]
            , text "and you will be unsubscribed from all future messages. You will need to send "
            , code [] [ text "start" ]
            , text "to the same number to receive messages again. We cannot reactivate you - the unsubscribing is handled by Twilio and     will stop you from receiving any messages from us. This is not a good idea if you want to sign up for things using this service."
            ]
        ]
