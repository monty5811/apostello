module Helpers exposing
    ( archiveCell
    , calculateSmsCost
    , decodeAlwaysTrue
    , formatDate
    , handleNotSaved
    , onClick
    , toggleSelectedPk
    , userFacingErrorMessage
    )

import Css
import Date
import DateFormat
import Html exposing (Attribute, Html, a, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onWithOptions)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import List.Extra as LE
import Notification as Notif


toggleSelectedPk : Int -> List Int -> List Int
toggleSelectedPk pk pks =
    case List.member pk pks of
        True ->
            LE.remove pk pks

        False ->
            pk :: pks


decodeAlwaysTrue : Decode.Decoder Bool
decodeAlwaysTrue =
    Decode.succeed True


userFacingErrorMessage : Http.Error -> String
userFacingErrorMessage err =
    case err of
        Http.BadUrl _ ->
            "That's a bad URL. Sorry."

        Http.NetworkError ->
            "Looks like there may be something wrong with your internet connection :("

        Http.BadStatus r ->
            r.body
                |> Decode.decodeString decodeErrResp
                |> Result.withDefault { status = "", error = "Something went wrong there. Sorry. (" ++ r.body ++ ")" }
                |> .error

        Http.BadPayload msg _ ->
            "Something went wrong there. Sorry. (" ++ msg ++ ")"

        Http.Timeout ->
            "It took too long to reach the server..."


type alias ErrResp =
    { status : String
    , error : String
    }


decodeErrResp : Decode.Decoder ErrResp
decodeErrResp =
    decode ErrResp
        |> required "status" Decode.string
        |> optional "error" Decode.string ""



-- update model after http errors:


handleNotSaved : { a | notifications : Notif.Notifications } -> ( { a | notifications : Notif.Notifications }, List (Cmd msg) )
handleNotSaved model =
    ( { model | notifications = Notif.addNotSaved model.notifications }, [] )



-- Pretty date format


formatDate : Maybe Date.Date -> String
formatDate date =
    case date of
        Just d ->
            DateFormat.format
                [ DateFormat.hourMilitaryFixed
                , DateFormat.text ":"
                , DateFormat.minuteFixed
                , DateFormat.text " - "
                , DateFormat.dayOfMonthSuffix
                , DateFormat.text " "
                , DateFormat.monthNameFirstThree
                ]
                d

        Nothing ->
            ""



-- calculate cost of sending an sms


calculateSmsCost : Float -> String -> Float
calculateSmsCost smsCostPerMsg msg =
    msg
        |> String.length
        |> toFloat
        |> flip (/) 160
        |> ceiling
        |> toFloat
        |> (*) smsCostPerMsg


archiveCell : Bool -> msg -> Html msg
archiveCell isArchived msg =
    a
        [ Css.btn
        , Css.btn_grey
        , Css.text_sm
        , onClick msg
        , id "archiveItemButton"
        ]
        [ text <| archiveText isArchived ]


archiveText : Bool -> String
archiveText isArchived =
    case isArchived of
        True ->
            "UnArchive"

        False ->
            "Archive"


onClick : msg -> Attribute msg
onClick message =
    onWithOptions "click" { stopPropagation = True, preventDefault = True } (Decode.succeed message)
