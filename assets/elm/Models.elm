module Models
    exposing
        ( FabModel(..)
        , Flags
        , Model
        , Settings
        , decodeFlags
        , initialModel
        )

import Data.User exposing (UserProfile, decodeUserProfile)
import Dict exposing (Dict)
import DjangoSend exposing (CSRFToken(CSRFToken))
import FilteringTable.Model as FT
import Forms.Model exposing (FormStatus(NoAction))
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Pages exposing (Page)
import Pages.Fragments.Notification.Model exposing (DjangoMessage, Notification, NotificationType(..))
import Store.Decode exposing (decodeDataStore)
import Store.Model exposing (DataStore, emptyDataStore)
import Time


-- Main Model


type alias Model =
    { page : Page
    , table : FT.Model
    , settings : Settings
    , dataStore : DataStore
    , fabModel : FabModel
    , notifications : Dict Int Notification
    , currentTime : Time.Time
    , formStatus : FormStatus
    }


initialModel : Settings -> String -> Page -> Model
initialModel settings dataStoreCache page =
    { page = page
    , table = FT.initial
    , settings = settings
    , dataStore = Result.withDefault emptyDataStore <| Decode.decodeString decodeDataStore dataStoreCache
    , fabModel = initialFabModel
    , notifications = Dict.empty
    , currentTime = 0
    , formStatus = NoAction
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
    , dataStoreCache : Maybe String
    }


decodeFlags : Decode.Decoder Flags
decodeFlags =
    decode Flags
        |> required "settings" decodeSettings
        |> required "dataStoreCache" (Decode.maybe Decode.string)



-- FAB model


type FabModel
    = MenuHidden
    | MenuVisible


initialFabModel : FabModel
initialFabModel =
    MenuHidden
