module Models
    exposing
        ( Flags
        , MenuModel(..)
        , Model
        , Settings
        , decodeFlags
        , initialModel
        )

import Data exposing (UserProfile, decodeUserProfile)
import DjangoSend exposing (CSRFToken(CSRFToken))
import FilteringTable as FT
import Forms.Model exposing (FormStatus(NoAction))
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Notification as Notif
import PageVisibility
import Pages exposing (Page)
import Store.Model exposing (DataStore, emptyDataStore)
import Time
import WebPush


-- Main Model


type alias Model =
    { page : Page
    , table : FT.Model
    , settings : Settings
    , dataStore : DataStore
    , notifications : Notif.Notifications
    , currentTime : Time.Time
    , formStatus : FormStatus
    , webPush : WebPush.Model
    , menuState : MenuModel
    , pageVisibility : PageVisibility.Visibility
    }


initialModel : Settings -> Page -> Model
initialModel settings page =
    { page = page
    , table = FT.initialModel
    , settings = settings
    , dataStore = emptyDataStore
    , notifications = Notif.empty
    , currentTime = 0
    , formStatus = NoAction
    , webPush = WebPush.initial
    , menuState = MenuHidden
    , pageVisibility = PageVisibility.Visible -- default to visible, perhaps, should do something more sophisticated on init
    }



-- Settings


type alias Settings =
    { csrftoken : CSRFToken
    , userPerms : UserProfile
    , twilioSendingCost : Float
    , twilioFromNumber : String
    , smsCharLimit : Int
    , defaultNumberPrefix : String
    , blockedKeywords : List String
    }


decodeSettings : Decode.Decoder Settings
decodeSettings =
    decode Settings
        |> required "csrftoken" (Decode.string |> Decode.andThen (\t -> Decode.succeed (CSRFToken t)))
        |> required "userPerms" decodeUserProfile
        |> required "twilioSendingCost" Decode.float
        |> required "twilioFromNumber" Decode.string
        |> required "smsCharLimit" Decode.int
        |> required "defaultNumberPrefix" Decode.string
        |> required "blockedKeywords" (Decode.list Decode.string)



--


type alias Flags =
    { settings : Settings
    }


decodeFlags : Decode.Decoder Flags
decodeFlags =
    decode Flags
        |> required "settings" decodeSettings



-- Menu model


type MenuModel
    = MenuHidden
    | MenuVisible
