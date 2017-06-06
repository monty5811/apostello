module Models
    exposing
        ( CSRFToken
        , FabModel(..)
        , Flags
        , Model
        , Settings
        , initialModel
        )

import Data.Store exposing (DataStore, decodeDataStore, emptyDataStore)
import Data.User exposing (UserProfile)
import Dict exposing (Dict)
import FilteringTable.Model as FT
import Forms.Model exposing (FormStatus(NoAction))
import Json.Decode as Decode
import Pages exposing (Page)
import Pages.Fragments.Notification.Model exposing (DjangoMessage, Notification, NotificationType(..))
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



--


type alias Flags =
    { settings : Settings
    , messages : List DjangoMessage
    , dataStoreCache : Maybe String
    }



-- CSRF Token - required for post requests


type alias CSRFToken =
    String



-- FAB model


type FabModel
    = MenuHidden
    | MenuVisible


initialFabModel : FabModel
initialFabModel =
    MenuHidden
