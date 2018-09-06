module Pages.OutboundTable exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (SmsOutbound, stringFromMDStatus)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html)
import RemoteList as RL


-- Model


type alias Model =
    { tableModel : FT.Model
    }


initialModel : Model
initialModel =
    { tableModel = FT.initialModel }



-- Update


type Msg
    = TableMsg FT.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        TableMsg tableMsg ->
            { model | tableModel = FT.update tableMsg model.tableModel }


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , sms : RL.RemoteList SmsOutbound
    , contactLink : { full_name : String, pk : Int } -> Html msg
    }


view : Props msg -> Model -> Html msg
view props { tableModel } =
    FT.defaultTable { top = props.tableMsg } tableHead tableModel (smsRow props) props.sms


tableHead : FT.Head
tableHead =
    FT.Head
        [ "To"
        , "Message"
        , "Sent"
        , "Status from Twilio"
        ]


smsRow : Props msg -> SmsOutbound -> FT.Row msg
smsRow props sms =
    let
        recipient =
            case sms.recipient of
                Just r ->
                    r

                Nothing ->
                    { full_name = "", pk = 0 }
    in
    FT.Row
        []
        [ FT.Cell [] [ props.contactLink recipient ]
        , FT.Cell [] [ Html.text sms.content ]
        , FT.Cell [ Css.collapsing ] [ Html.text <| formatDate sms.time_sent ]
        , FT.Cell [ Css.collapsing ] [ Html.text <| stringFromMDStatus sms.status ]
        ]
        (toString sms.pk)
