module Models
    exposing
        ( Flags
        , Model
        , Settings
        , TwilioSettings
        , decodeFlags
        , initialModel
        )

import Data exposing (UserProfile, decodeUserProfile)
import DjangoSend exposing (CSRFToken(CSRFToken))
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Notification as Notif
import PageVisibility
import Pages exposing (Page)
import Store.Model exposing (DataStore, emptyDataStore)
import Time


-- Main Model


type alias Model =
    { page : Page
    , settings : Settings
    , dataStore : DataStore
    , notifications : Notif.Notifications
    , currentTime : Time.Time
    , pageVisibility : PageVisibility.Visibility
    }


initialModel : Settings -> Page -> Model
initialModel settings page =
    { page = page
    , settings = settings
    , dataStore = emptyDataStore
    , notifications = Notif.empty
    , currentTime = 0
    , pageVisibility = PageVisibility.Visible -- default to visible, perhaps, should do something more sophisticated on init
    }



-- Settings


type alias Settings =
    { csrftoken : CSRFToken
    , userPerms : UserProfile
    , twilio : Maybe TwilioSettings
    , isEmailSetup : Bool
    , smsCharLimit : Int
    , defaultNumberPrefix : String
    , blockedKeywords : List String
    }


type alias TwilioSettings =
    { sendingCost : Float
    , fromNumber : String
    }


decodeSettings : Decode.Decoder Settings
decodeSettings =
    decode Settings
        |> required "csrftoken" (Decode.string |> Decode.andThen (\t -> Decode.succeed (CSRFToken t)))
        |> required "userPerms" decodeUserProfile
        |> required "twilio" (Decode.maybe decodeTwilioSettings)
        |> required "isEmailSetup" Decode.bool
        |> required "smsCharLimit" Decode.int
        |> required "defaultNumberPrefix" Decode.string
        |> required "blockedKeywords" (Decode.list Decode.string)


decodeTwilioSettings : Decode.Decoder TwilioSettings
decodeTwilioSettings =
    decode TwilioSettings
        |> required "sending_cost" Decode.float
        |> required "from_num" Decode.string



--


type alias Flags =
    { settings : Settings
    }


decodeFlags : Decode.Decoder Flags
decodeFlags =
    decode Flags
        |> required "settings" decodeSettings
