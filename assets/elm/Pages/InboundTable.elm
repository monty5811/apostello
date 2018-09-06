module Pages.InboundTable exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (SmsInbound)
import FilteringTable as FT
import Helpers exposing (formatDate)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
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



-- Main view


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , sms : RL.RemoteList SmsInbound
    , reprocessSms : Int -> msg
    , keywordFormLink : SmsInbound -> Html msg
    , contactPageLink : SmsInbound -> Html msg
    , replyPageLink : SmsInbound -> Html msg
    }


view : Props msg -> Model -> Html msg
view props { tableModel } =
    FT.defaultTable { top = props.tableMsg } head tableModel (smsRow props) props.sms


head : FT.Head
head =
    FT.Head [ "From", "Keyword", "Message", "Time", "" ]


smsRow : Props msg -> SmsInbound -> FT.Row msg
smsRow props sms =
    FT.Row
        []
        [ recipientCell props sms
        , keywordCell props sms
        , FT.Cell [] [ Html.text sms.content ]
        , FT.Cell [ Css.collapsing ] [ Html.text <| formatDate sms.time_received ]
        , reprocessCell props sms
        ]
        (toString sms.pk)


recipientCell : Props msg -> SmsInbound -> FT.Cell msg
recipientCell props sms =
    FT.Cell
        [ Css.collapsing ]
        [ props.replyPageLink sms
        , props.contactPageLink sms
        ]


keywordCell : Props msg -> SmsInbound -> FT.Cell msg
keywordCell props sms =
    case sms.matched_keyword of
        "#" ->
            FT.Cell [ Css.collapsing ] [ Html.b [] [ Html.text sms.matched_keyword ] ]

        "No Match" ->
            FT.Cell [ Css.collapsing ] [ Html.b [] [ Html.text sms.matched_keyword ] ]

        _ ->
            FT.Cell [ Css.collapsing ] [ Html.b [] [ props.keywordFormLink sms ] ]


reprocessCell : Props msg -> SmsInbound -> FT.Cell msg
reprocessCell props sms =
    FT.Cell
        [ Css.collapsing ]
        [ Html.a
            [ A.id "reingestButton"
            , E.onClick (props.reprocessSms sms.pk)
            , Css.btn
            , Css.btn_blue
            ]
            [ Html.text "Reprocess" ]
        ]
