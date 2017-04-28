module Update.SendAdhoc exposing (..)

import Date
import DjangoSend exposing (rawPost)
import Encode exposing (encodeMaybeDate)
import Helpers exposing (calculateSmsCost)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import List.Extra as LE
import Messages exposing (..)
import Models exposing (Model, CSRFToken)
import Models.DjangoMessage exposing (DjangoMessage)
import Models.FormStatus exposing (FormStatus(..))
import Models.SendAdhocForm exposing (SendAdhocModel, initialSendAdhocModel, decodeSendAdhocFormResp)
import Pages exposing (Page)
import Regex
import Update.Notification as Notif
import View.FilteringTable as FT
import Urls


update : SendAdhocMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    let
        ( saModel, cmds, messages ) =
            updateSAModel msg model.settings.csrftoken model.sendAdhoc

        newModel =
            { model | sendAdhoc = updateCost model.settings.twilioSendingCost saModel }
    in
        ( List.foldl Notif.createFromDjangoMessageNoDestroy newModel messages
        , cmds
        )


updateSAModel : SendAdhocMsg -> CSRFToken -> SendAdhocModel -> ( SendAdhocModel, List (Cmd Msg), List DjangoMessage )
updateSAModel msg csrftoken model =
    case msg of
        -- form display:
        UpdateContent text ->
            ( { model | content = text }, [], [] )

        UpdateDate date ->
            ( { model | date = date |> Date.fromString |> Result.toMaybe }, [], [] )

        ToggleSelectedContact pk ->
            ( { model | selectedContacts = toggleSelectedContact pk model.selectedContacts }, [], [] )

        UpdateAdhocFilter text ->
            ( { model | adhocFilter = FT.textToRegex text }, [], [] )

        -- talking to server
        PostForm ->
            case model.cost of
                Nothing ->
                    ( model, [], [] )

                Just _ ->
                    ( { model | status = InProgress }, [ postForm csrftoken model ], [] )

        ReceiveFormResp (Ok resp) ->
            let
                r =
                    resp.body |> Decode.decodeString decodeSendAdhocFormResp
            in
                case r of
                    Ok data ->
                        ( { model | status = Success, errors = data.errors } |> wipeForm, [], data.messages )

                    Err _ ->
                        ( { model | status = Failed "" }, [], [] )

        ReceiveFormResp (Err e) ->
            case e of
                Http.BadStatus resp ->
                    let
                        r =
                            resp.body |> Decode.decodeString decodeSendAdhocFormResp
                    in
                        case r of
                            Ok data ->
                                ( { model | status = Failed "", errors = data.errors }, [], data.messages )

                            Err _ ->
                                ( { model | status = Failed "" }, [], [] )

                _ ->
                    ( { model | status = Failed "" }
                    , []
                    , [ { type_ = "error", text = "Something went wrong there, you may want to check the logs before trying again." } ]
                    )


wipeForm : SendAdhocModel -> SendAdhocModel
wipeForm model =
    { model
        | content = ""
        , selectedContacts = []
        , adhocFilter = Regex.regex ""
        , date = Nothing
    }


resetForm : Page -> SendAdhocModel
resetForm page =
    initialSendAdhocModel page


updateCost : Float -> SendAdhocModel -> SendAdhocModel
updateCost smsCost model =
    case model.content of
        "" ->
            { model | cost = Nothing }

        c ->
            case model.selectedContacts |> List.length of
                0 ->
                    { model | cost = Nothing }

                n ->
                    { model | cost = Just (calculateSmsCost (smsCost * toFloat n) c) }


postForm : CSRFToken -> SendAdhocModel -> Cmd Msg
postForm csrftoken model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipients"
              , Encode.list (model.selectedContacts |> List.map Encode.int)
              )
            , ( "scheduled_time", encodeMaybeDate model.date )
            ]
    in
        rawPost csrftoken Urls.sendAdhoc body
            |> Http.send (SendAdhocMsg << ReceiveFormResp)


toggleSelectedContact : Int -> List Int -> List Int
toggleSelectedContact pk pks =
    case List.member pk pks of
        True ->
            LE.remove pk pks

        False ->
            pk :: pks
