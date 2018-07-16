module Pages.Wall exposing (view)

import Css
import Data exposing (SmsInbound)
import Html exposing (Html)
import RemoteList as RL


-- Main view


view : RL.RemoteList SmsInbound -> Html msg
view sms =
    Html.div []
        (sms
            |> RL.toList
            |> List.filter (\s -> s.display_on_wall)
            |> List.map smsCard
        )


smsCard : SmsInbound -> Html msg
smsCard sms =
    Html.div [ Css.wallSms ]
        [ Html.p []
            [ Html.span [ Css.text_grey ] [ Html.text <| firstWord sms ]
            , Html.text <| restOfMessage sms
            ]
        ]


firstWord : SmsInbound -> String
firstWord sms =
    sms.content
        |> String.split " "
        |> List.head
        |> Maybe.withDefault ""


restOfMessage : SmsInbound -> String
restOfMessage sms =
    sms.content
        |> String.split " "
        |> List.tail
        |> Maybe.withDefault []
        |> String.join " "
        |> (++) " "
