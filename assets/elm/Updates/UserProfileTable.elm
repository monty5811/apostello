module Updates.UserProfileTable exposing (update)

import DjangoSend exposing (post)
import Encoders exposing (..)
import Helpers exposing (handleNotSaved)
import Http
import Messages exposing (..)
import Models exposing (..)
import Updates.DataStore exposing (updateUserProfiles)
import Urls


update : UserProfileTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleField profile ->
            ( { model
                | dataStore = updateUserProfiles model.dataStore [ profile ]
              }
            , [ toggleField model.settings.csrftoken profile ]
            )

        ReceiveToggleProfile (Ok profile) ->
            ( { model
                | dataStore = updateUserProfiles model.dataStore [ profile ]
              }
            , []
            )

        ReceiveToggleProfile (Err _) ->
            handleNotSaved model


toggleField : CSRFToken -> UserProfile -> Cmd Msg
toggleField csrftoken profile =
    let
        url =
            Urls.userprofile profile.pk

        body =
            [ ( "user_profile", encodeUserProfile <| profile ) ]
    in
        post csrftoken url body userprofileDecoder
            |> Http.send (UserProfileTableMsg << ReceiveToggleProfile)
