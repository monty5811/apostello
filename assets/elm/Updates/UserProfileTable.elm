module Updates.UserProfileTable exposing (update)

import Actions exposing (determineRespCmd)
import Decoders exposing (userprofileDecoder)
import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)


update : UserProfileTableMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadUserProfileTableResp (Ok resp) ->
            ( { model
                | loadingStatus = determineLoadingStatus resp
                , userProfileTable = updateUserProfiles model.userProfileTable resp.results
              }
            , determineRespCmd UserProfileTable resp
            )

        LoadUserProfileTableResp (Err _) ->
            handleLoadingFailed model

        ToggleField profile ->
            ( { model
                | userProfileTable = updateUserProfiles model.userProfileTable [ profile ]
              }
            , toggleField model.csrftoken profile
            )

        ReceiveToggleProfile (Ok profile) ->
            ( { model
                | userProfileTable = updateUserProfiles model.userProfileTable [ profile ]
              }
            , Cmd.none
            )

        ReceiveToggleProfile (Err _) ->
            handleNotSaved model


updateUserProfiles : UserProfileTableModel -> List UserProfile -> UserProfileTableModel
updateUserProfiles model profiles =
    { model | userprofiles = mergeItems model.userprofiles profiles }


toggleField : CSRFToken -> UserProfile -> Cmd Msg
toggleField csrftoken profile =
    let
        url =
            "/api/v1/users/profiles/" ++ (toString profile.pk)

        body =
            encodeUserProfile profile
                |> Http.jsonBody
    in
        post url body csrftoken userprofileDecoder
            |> Http.send (UserProfileTableMsg << ReceiveToggleProfile)


encodeUserProfile : UserProfile -> Encode.Value
encodeUserProfile record =
    Encode.object
        [ ( "user_profile", encodeUserProfileUser_profile <| record )
        ]


encodeUserProfileUser_profileUser : UserProfileUser_profileUser -> Encode.Value
encodeUserProfileUser_profileUser record =
    Encode.object
        [ ( "email", Encode.string <| record.email )
        , ( "username", Encode.string <| record.username )
        ]


encodeUserProfileUser_profile : UserProfileUser_profile -> Encode.Value
encodeUserProfileUser_profile record =
    Encode.object
        [ ( "pk", Encode.int <| record.pk )
        , ( "user", encodeUserProfileUser_profileUser <| record.user )
        , ( "url", Encode.string <| record.url )
        , ( "approved", Encode.bool <| record.approved )
        , ( "can_see_groups", Encode.bool <| record.can_see_groups )
        , ( "can_see_contact_names", Encode.bool <| record.can_see_contact_names )
        , ( "can_see_keywords", Encode.bool <| record.can_see_keywords )
        , ( "can_see_outgoing", Encode.bool <| record.can_see_outgoing )
        , ( "can_see_incoming", Encode.bool <| record.can_see_incoming )
        , ( "can_send_sms", Encode.bool <| record.can_send_sms )
        , ( "can_see_contact_nums", Encode.bool <| record.can_see_contact_nums )
        , ( "can_import", Encode.bool <| record.can_import )
        , ( "can_archive", Encode.bool <| record.can_archive )
        ]


type alias UserProfileUser_profileUser =
    { email : String
    , username : String
    }


type alias UserProfileUser_profile =
    { pk : Int
    , user : UserProfileUser_profileUser
    , url : String
    , approved : Bool
    , can_see_groups : Bool
    , can_see_contact_names : Bool
    , can_see_keywords : Bool
    , can_see_outgoing : Bool
    , can_see_incoming : Bool
    , can_send_sms : Bool
    , can_see_contact_nums : Bool
    , can_import : Bool
    , can_archive : Bool
    }
