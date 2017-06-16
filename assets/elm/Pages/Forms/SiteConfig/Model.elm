module Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel, decodeSiteConfigFormModel)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Regex


type alias SiteConfigFormModel =
    { site_name : String
    , sms_char_limit : Int
    , default_number_prefix : String
    , disable_all_replies : Bool
    , disable_email_login_form : Bool
    , office_email : String
    , auto_add_new_groups : List Int
    , slack_url : String
    , sync_elvanto : Bool
    , not_approved_msg : String
    , email_host : String
    , email_port : Maybe Int
    , email_username : String
    , email_password : String
    , email_from : String
    , groupsFilter : Regex.Regex
    }


decodeSiteConfigFormModel : Decode.Decoder SiteConfigFormModel
decodeSiteConfigFormModel =
    decode SiteConfigFormModel
        |> required "site_name" Decode.string
        |> required "sms_char_limit" Decode.int
        |> required "default_number_prefix" Decode.string
        |> required "disable_all_replies" Decode.bool
        |> required "disable_email_login_form" Decode.bool
        |> required "office_email" Decode.string
        |> required "auto_add_new_groups" (Decode.list Decode.int)
        |> required "slack_url" Decode.string
        |> required "sync_elvanto" Decode.bool
        |> required "not_approved_msg" Decode.string
        |> required "email_host" Decode.string
        |> required "email_port" (Decode.maybe Decode.int)
        |> required "email_username" Decode.string
        |> required "email_password" Decode.string
        |> required "email_from" Decode.string
        |> hardcoded (Regex.regex "")
