module Update exposing (update)

import Actions exposing (fetchData)
import Messages exposing (..)
import Models exposing (..)
import Helpers exposing (collectPeople)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Load data
        LoadData ->
            ( { model | loadingStatus = Waiting }, (fetchData model.csrftoken) )

        LoadDataSuccess groups ->
            ( { model
                | groups = groups
                , people = (collectPeople groups)
                , loadingStatus = Finished
              }
            , Cmd.none
            )

        LoadDataError error ->
            ( { model | loadingStatus = LoadingFailed }, Cmd.none )

        UpdateQueryString string ->
            ( { model | query = Just string }, Cmd.none )
