module Data.User exposing (User, UserProfile, decodeUser, decodeUserProfile, encodeUser, encodeUserProfile)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias UserProfile =
    { pk : Int
    , user : User
    , approved : Bool
    , message_cost_limit : Float
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


decodeUserProfile : Decode.Decoder UserProfile
decodeUserProfile =
    decode UserProfile
        |> required "pk" Decode.int
        |> required "user" decodeUser
        |> required "approved" Decode.bool
        |> required "message_cost_limit" Decode.float
        |> required "can_see_groups" Decode.bool
        |> required "can_see_contact_names" Decode.bool
        |> required "can_see_keywords" Decode.bool
        |> required "can_see_outgoing" Decode.bool
        |> required "can_see_incoming" Decode.bool
        |> required "can_send_sms" Decode.bool
        |> required "can_see_contact_nums" Decode.bool
        |> required "can_import" Decode.bool
        |> required "can_archive" Decode.bool


encodeUserProfile : UserProfile -> Encode.Value
encodeUserProfile record =
    Encode.object
        [ ( "pk", Encode.int record.pk )
        , ( "user", encodeUser record.user )
        , ( "approved", Encode.bool record.approved )
        , ( "message_cost_limit", Encode.float record.message_cost_limit )
        , ( "can_see_groups", Encode.bool record.can_see_groups )
        , ( "can_see_contact_names", Encode.bool record.can_see_contact_names )
        , ( "can_see_keywords", Encode.bool record.can_see_keywords )
        , ( "can_see_outgoing", Encode.bool record.can_see_outgoing )
        , ( "can_see_incoming", Encode.bool record.can_see_incoming )
        , ( "can_send_sms", Encode.bool record.can_send_sms )
        , ( "can_see_contact_nums", Encode.bool record.can_see_contact_nums )
        , ( "can_import", Encode.bool record.can_import )
        , ( "can_archive", Encode.bool record.can_archive )
        ]


type alias User =
    { pk : Int
    , email : String
    , username : String
    , is_staff : Bool
    , is_social : Bool
    }


decodeUser : Decode.Decoder User
decodeUser =
    decode User
        |> required "pk" Decode.int
        |> required "email" Decode.string
        |> required "username" Decode.string
        |> required "is_staff" Decode.bool
        |> required "is_social" Decode.bool


encodeUser : User -> Encode.Value
encodeUser user =
    Encode.object
        [ ( "pk", Encode.int user.pk )
        , ( "email", Encode.string user.email )
        , ( "username", Encode.string user.username )
        , ( "is_staff", Encode.bool user.is_staff )
        , ( "is_social", Encode.bool user.is_social )
        ]
