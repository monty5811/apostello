module Update exposing (update)

import Actions exposing (fetchData)
import Helpers exposing (collectPeople)
import Messages exposing (..)
import Models exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Load data
        LoadData ->
            ( { model | loadingStatus = Waiting }, fetchData )

        LoadDataResp (Ok groups) ->
            ( { model
                | groups = groups
                , people = (collectPeople groups)
                , loadingStatus = Finished
              }
            , Cmd.none
            )

        LoadDataResp (Err _) ->
            ( { model | loadingStatus = LoadingFailed }, Cmd.none )

        UpdateQueryString string ->
            ( { model | query = Just string }, Cmd.none )
