module Pages.UserProfileTable.Update exposing (update)

import Data.Store.Update exposing (updateUserProfiles)
import Data.User exposing (UserProfile, decodeUserProfile, encodeUserProfile)
import DjangoSend exposing (post)
import Helpers exposing (handleNotSaved)
import Http
import Messages exposing (Msg(UserProfileTableMsg))
import Models exposing (CSRFToken, Model)
import Pages.UserProfileTable.Messages exposing (UserProfileTableMsg(ReceiveToggleProfile, ToggleField))
import Urls


update : UserProfileTableMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        ToggleField profile ->
            ( { model
                | dataStore = updateUserProfiles model.dataStore [ profile ] <| Just "dummy"
              }
            , [ toggleField model.settings.csrftoken profile ]
            )

        ReceiveToggleProfile (Ok profile) ->
            ( { model
                | dataStore = updateUserProfiles model.dataStore [ profile ] <| Just "dummy"
              }
            , []
            )

        ReceiveToggleProfile (Err _) ->
            handleNotSaved model


toggleField : CSRFToken -> UserProfile -> Cmd Msg
toggleField csrftoken profile =
    let
        url =
            Urls.api_user_profile_update profile.pk

        body =
            [ ( "user_profile", encodeUserProfile <| profile ) ]
    in
    post csrftoken url body decodeUserProfile
        |> Http.send (UserProfileTableMsg << ReceiveToggleProfile)
