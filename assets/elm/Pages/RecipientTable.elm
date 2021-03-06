module Pages.RecipientTable exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (Recipient)
import FilteringTable as FT
import Helpers exposing (archiveCell, formatDate)
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
    , recipients : RL.RemoteList Recipient
    , toggleRecipientArchive : Bool -> Int -> msg
    , contactLink : Recipient -> Html msg
    }


view : Props msg -> Model -> Html msg
view props { tableModel } =
    FT.defaultTable { top = props.tableMsg } head tableModel (recipientRow props) props.recipients


head : FT.Head
head =
    FT.Head
        [ "Name"
        , "Last Message"
        , "Received"
        , ""
        ]


recipientRow : Props msg -> Recipient -> FT.Row msg
recipientRow props recipient =
    let
        timeReceived =
            Maybe.andThen .time_received recipient.last_sms

        content =
            case recipient.last_sms of
                Just sms ->
                    sms.content

                Nothing ->
                    ""
    in
    FT.Row
        []
        [ FT.Cell []
            [ props.contactLink recipient
            , doNotReplyIndicator recipient.do_not_reply
            , blockingIndicator recipient.is_blocking
            , neverContactIndicator recipient.never_contact
            ]
        , FT.Cell [] [ Html.text content ]
        , FT.Cell [] [ Html.text <| formatDate timeReceived ]
        , FT.Cell [ Css.collapsing ] [ archiveCell recipient.is_archived (props.toggleRecipientArchive recipient.is_archived recipient.pk) ]
        ]
        (toString recipient.pk)


doNotReplyIndicator : Bool -> Html msg
doNotReplyIndicator reply =
    case reply of
        True ->
            Html.span [ Css.pill_sm, Css.pill_orange, Css.displayInline ] [ Html.text "Do Not Reply" ]

        False ->
            Html.text ""


blockingIndicator : Bool -> Html msg
blockingIndicator blocking =
    case blocking of
        True ->
            Html.span [ Css.pill_sm, Css.pill_red, Css.displayInline ] [ Html.text "Blocked Us" ]

        False ->
            Html.text ""


neverContactIndicator : Bool -> Html msg
neverContactIndicator bool =
    case bool of
        True ->
            Html.span [ Css.pill_sm, Css.pill_red, Css.displayInline ] [ Html.text "Never Contact" ]

        False ->
            Html.text ""
