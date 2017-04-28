module Update.SendGroup exposing (..)

import Date
import DjangoSend exposing (rawPost)
import Encode exposing (encodeMaybeDate)
import Helpers exposing (calculateSmsCost)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (Model, CSRFToken)
import Models.Apostello exposing (RecipientGroup, nullGroup)
import Models.DjangoMessage exposing (DjangoMessage)
import Models.FormStatus exposing (FormStatus(..))
import Models.SendGroupForm exposing (SendGroupModel, initialSendGroupModel, decodeSendGroupFormResp)
import Pages exposing (Page)
import Regex
import Update.Notification as Notif
import View.FilteringTable as FT
import Urls


update : SendGroupMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    let
        ( sgModel, cmds, messages ) =
            updateSGModel msg model.settings.csrftoken model.sendGroup
    in
        ( List.foldl
            Notif.createFromDjangoMessageNoDestroy
            { model | sendGroup = sgModel |> updateCost model.dataStore.groups }
            messages
        , cmds
        )


updateSGModel : SendGroupMsg -> CSRFToken -> SendGroupModel -> ( SendGroupModel, List (Cmd Msg), List DjangoMessage )
updateSGModel msg csrftoken model =
    case msg of
        -- form display:
        UpdateSGContent text ->
            ( { model | content = text }, [], [] )

        UpdateSGDate date ->
            ( { model | date = date |> Date.fromString |> Result.toMaybe }, [], [] )

        SelectGroup pk ->
            ( { model | selectedPk = Just pk }, [], [] )

        UpdateGroupFilter str ->
            ( { model | groupFilter = FT.textToRegex str }, [], [] )

        -- talking to server
        PostSGForm ->
            case model.cost of
                Nothing ->
                    ( model, [], [] )

                Just _ ->
                    ( { model | status = InProgress }, [ postForm csrftoken model ], [] )

        ReceiveSGFormResp (Ok resp) ->
            let
                r =
                    resp.body |> Decode.decodeString decodeSendGroupFormResp
            in
                case r of
                    Ok data ->
                        ( { model | status = Success, errors = data.errors } |> wipeForm, [], data.messages )

                    Err _ ->
                        ( { model | status = Failed "" }, [], [] )

        ReceiveSGFormResp (Err e) ->
            case e of
                Http.BadStatus resp ->
                    let
                        r =
                            resp.body |> Decode.decodeString decodeSendGroupFormResp
                    in
                        case r of
                            Ok data ->
                                ( { model | status = Failed "", errors = data.errors }, [], data.messages )

                            Err _ ->
                                ( { model | status = Failed "" }, [], [] )

                _ ->
                    ( { model | status = Failed "" }
                    , []
                    , [ { type_ = "error"
                        , text = "Something went wrong there, you may want to check the logs before trying again."
                        }
                      ]
                    )


wipeForm : SendGroupModel -> SendGroupModel
wipeForm model =
    { model
        | content = ""
        , selectedPk = Nothing
        , date = Nothing
        , groupFilter = Regex.regex ""
    }


resetForm : Page -> SendGroupModel
resetForm page =
    initialSendGroupModel page


updateCost : List RecipientGroup -> SendGroupModel -> SendGroupModel
updateCost groups model =
    case model.content of
        "" ->
            { model | cost = Nothing }

        c ->
            case model.selectedPk of
                Nothing ->
                    { model | cost = Nothing }

                Just pk ->
                    let
                        groupCost =
                            groups
                                |> List.filter (\x -> x.pk == pk)
                                |> List.head
                                |> Maybe.withDefault nullGroup
                                |> .cost
                    in
                        { model | cost = Just (calculateSmsCost groupCost c) }


postForm : CSRFToken -> SendGroupModel -> Cmd Msg
postForm csrftoken model =
    let
        body =
            [ ( "content", Encode.string model.content )
            , ( "recipient_group", Encode.int (Maybe.withDefault 0 model.selectedPk) )
            , ( "scheduled_time", encodeMaybeDate model.date )
            ]
    in
        rawPost csrftoken Urls.sendGroup body
            |> Http.send (SendGroupMsg << ReceiveSGFormResp)
