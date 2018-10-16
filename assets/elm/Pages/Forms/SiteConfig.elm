module Pages.Forms.SiteConfig exposing
    ( Model
    , Msg(..)
    , SiteConfigModel
    , decodeSiteConfigModel
    , init
    , initialModel
    , update
    , view
    )

import Data exposing (RecipientGroup)
import Date
import DateTimePicker
import DjangoSend
import Encode
import FilteringTable exposing (textToRegex)
import Form as F exposing (defaultFieldGroupConfig)
import Helpers exposing (onClick, toggleSelectedPk, userFacingErrorMessage)
import Html exposing (Html)
import Html.Attributes as A
import Http
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Json.Encode as Encode
import Pages.Forms.Meta.SiteConfig exposing (meta)
import Regex
import RemoteList as RL
import Urls


init : Cmd Msg
init =
    Http.get Urls.api_site_config decodeSiteConfigModel
        |> Http.send ReceiveInitialData


type alias Model =
    { form : F.Form SiteConfigModel DirtyState
    }


type alias DirtyState =
    { twilio_sending_cost : Maybe String
    , sms_char_limit : Maybe String
    , sms_expiration_date : Maybe String
    , sms_rolling_expiration_days : Maybe String
    , email_port : Maybe String
    , datePickerSmsExpiredState : DateTimePicker.State
    , groupsFilter : Regex.Regex
    }


initialDirtyState : DirtyState
initialDirtyState =
    { twilio_sending_cost = Nothing
    , sms_char_limit = Nothing
    , sms_expiration_date = Nothing
    , sms_rolling_expiration_days = Nothing
    , email_port = Nothing
    , datePickerSmsExpiredState = DateTimePicker.initialState
    , groupsFilter = Regex.regex ""
    }


initialModel : Model
initialModel =
    { form = F.formLoading }


type alias SiteConfigModel =
    { site_name : String
    , sms_char_limit : Int
    , default_number_prefix : String
    , disable_all_replies : Bool
    , disable_email_login_form : Bool
    , office_email : String
    , auto_add_new_groups : List Int
    , sms_expiration_date : Maybe Date.Date
    , sms_rolling_expiration_days : Maybe Int
    , slack_url : String
    , sync_elvanto : Bool
    , not_approved_msg : String
    , email_host : Maybe String
    , email_port : Maybe Int
    , email_username : Maybe String
    , email_password : Maybe String
    , email_from : Maybe String
    , twilio_account_sid : Maybe String
    , twilio_auth_token : Maybe String
    , twilio_from_num : Maybe String
    , twilio_sending_cost : Maybe Float
    }


decodeSiteConfigModel : Decode.Decoder SiteConfigModel
decodeSiteConfigModel =
    decode SiteConfigModel
        |> required "site_name" Decode.string
        |> required "sms_char_limit" Decode.int
        |> required "default_number_prefix" Decode.string
        |> required "disable_all_replies" Decode.bool
        |> required "disable_email_login_form" Decode.bool
        |> required "office_email" Decode.string
        |> required "auto_add_new_groups" (Decode.list Decode.int)
        |> required "sms_expiration_date" (Decode.maybe date)
        |> required "sms_rolling_expiration_days" (Decode.maybe Decode.int)
        |> required "slack_url" Decode.string
        |> required "sync_elvanto" Decode.bool
        |> required "not_approved_msg" Decode.string
        |> required "email_host" (Decode.maybe Decode.string)
        |> required "email_port" (Decode.maybe Decode.int)
        |> required "email_username" (Decode.maybe Decode.string)
        |> required "email_password" (Decode.maybe Decode.string)
        |> required "email_from" (Decode.maybe Decode.string)
        |> required "twilio_account_sid" (Decode.maybe Decode.string)
        |> required "twilio_auth_token" (Decode.maybe Decode.string)
        |> required "twilio_from_num" (Decode.maybe Decode.string)
        |> required "twilio_sending_cost" (Decode.maybe Decode.float)



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ReceiveInitialData (Result Http.Error SiteConfigModel)


type InputMsg
    = UpdateTwilioFromNum String
    | UpdateTwilioSid String
    | UpdateTwilioAuthToken String
    | UpdateTwilioSendCost String
    | UpdateSiteNameField String
    | UpdateSmsCharLimitField String
    | UpdateDefaultPrefixField String
    | UpdateDisableRepliesField
    | UpdateDisableLoginEmailField
    | UpdateOfficeEmailField String
    | UpdateAutoAddGroupsField Int
    | UpdateSmsExpiredDate DateTimePicker.State (Maybe Date.Date)
    | UpdateRollingExpiration String
    | UpdateSlackUrlField String
    | UpdateSyncElvantoField
    | UpdateNotApprovedField String
    | UpdateEmailHostField String
    | UpdateEmailPortField String
    | UpdateEmailUserField String
    | UpdateEmailPassField String
    | UpdateEmailFromField String
    | UpdateGroupsFilter String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        ReceiveInitialData (Ok siteConfig) ->
            F.UpdateResp
                { model | form = F.startUpdating siteConfig initialDirtyState }
                (DateTimePicker.initialCmd
                    (initSmsExpireDate siteConfig)
                    initialDirtyState.datePickerSmsExpiredState
                )
                []
                Nothing

        ReceiveInitialData (Err err) ->
            F.UpdateResp
                { model | form = F.toError <| userFacingErrorMessage err }
                Cmd.none
                []
                Nothing

        InputMsg inputMsg ->
            F.UpdateResp
                { model | form = F.updateField (updateInput inputMsg) model.form }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postCmd props.csrftoken model)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


initSmsExpireDate : SiteConfigModel -> DateTimePicker.State -> Maybe Date.Date -> Msg
initSmsExpireDate siteConfig datePickerSmsExpiredState _ =
    InputMsg (UpdateSmsExpiredDate datePickerSmsExpiredState siteConfig.sms_expiration_date)


updateInput : InputMsg -> SiteConfigModel -> DirtyState -> ( SiteConfigModel, DirtyState )
updateInput msg siteConfig dirtyState =
    case msg of
        UpdateTwilioFromNum text ->
            ( { siteConfig | twilio_from_num = Just text }, dirtyState )

        UpdateTwilioSid text ->
            ( { siteConfig | twilio_account_sid = Just text }, dirtyState )

        UpdateTwilioAuthToken text ->
            ( { siteConfig | twilio_auth_token = Just text }, dirtyState )

        UpdateTwilioSendCost text ->
            case String.toFloat text of
                Ok num ->
                    ( { siteConfig | twilio_sending_cost = Just num }, { dirtyState | twilio_sending_cost = Nothing } )

                Err _ ->
                    ( siteConfig, { dirtyState | twilio_sending_cost = Just text } )

        UpdateSiteNameField text ->
            ( { siteConfig | site_name = text }, dirtyState )

        UpdateSmsCharLimitField text ->
            case String.toInt text of
                Ok num ->
                    ( { siteConfig | sms_char_limit = num }, { dirtyState | sms_char_limit = Nothing } )

                Err _ ->
                    ( siteConfig, { dirtyState | sms_char_limit = Just text } )

        UpdateDefaultPrefixField text ->
            ( { siteConfig | default_number_prefix = text }, dirtyState )

        UpdateDisableRepliesField ->
            ( { siteConfig | disable_all_replies = not siteConfig.disable_all_replies }, dirtyState )

        UpdateDisableLoginEmailField ->
            ( { siteConfig | disable_email_login_form = not siteConfig.disable_email_login_form }, dirtyState )

        UpdateOfficeEmailField text ->
            ( { siteConfig | office_email = text }, dirtyState )

        UpdateAutoAddGroupsField pk ->
            ( { siteConfig | auto_add_new_groups = toggleSelectedPk pk siteConfig.auto_add_new_groups }, dirtyState )

        UpdateSmsExpiredDate state maybeDate ->
            ( { siteConfig | sms_expiration_date = maybeDate }, { dirtyState | datePickerSmsExpiredState = state } )

        UpdateRollingExpiration text ->
            let
                maybeNum =
                    text
                        |> String.toInt
                        |> Result.toMaybe
            in
            case maybeNum of
                Just num ->
                    ( { siteConfig | sms_rolling_expiration_days = maybeNum }, { dirtyState | sms_rolling_expiration_days = Nothing } )

                Nothing ->
                    ( { siteConfig | sms_rolling_expiration_days = maybeNum }, { dirtyState | sms_rolling_expiration_days = Just text } )

        UpdateSlackUrlField text ->
            ( { siteConfig | slack_url = text }, dirtyState )

        UpdateSyncElvantoField ->
            ( { siteConfig | sync_elvanto = not siteConfig.sync_elvanto }, dirtyState )

        UpdateNotApprovedField text ->
            ( { siteConfig | not_approved_msg = text }, dirtyState )

        UpdateEmailHostField text ->
            ( { siteConfig | email_host = Just text }, dirtyState )

        UpdateEmailPortField text ->
            case String.toInt text of
                Ok num ->
                    ( { siteConfig | email_port = Just num }, { dirtyState | email_port = Nothing } )

                Err _ ->
                    ( siteConfig, { dirtyState | email_port = Just text } )

        UpdateEmailUserField text ->
            ( { siteConfig | email_username = Just text }, dirtyState )

        UpdateEmailPassField text ->
            ( { siteConfig | email_password = Just text }, dirtyState )

        UpdateEmailFromField text ->
            ( { siteConfig | email_from = Just text }, dirtyState )

        UpdateGroupsFilter text ->
            ( siteConfig, { dirtyState | groupsFilter = textToRegex text } )


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    case F.getCurrent model.form of
        Just item ->
            DjangoSend.rawPost csrf Urls.api_site_config (toBody item)
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none


toBody : SiteConfigModel -> List ( String, Encode.Value )
toBody siteConfig =
    [ ( "site_name", Encode.string siteConfig.site_name )
    , ( "sms_char_limit", Encode.int siteConfig.sms_char_limit )
    , ( "default_number_prefix", Encode.string siteConfig.default_number_prefix )
    , ( "disable_all_replies", Encode.bool siteConfig.disable_all_replies )
    , ( "disable_email_login_form", Encode.bool siteConfig.disable_email_login_form )
    , ( "office_email", Encode.string siteConfig.office_email )
    , ( "auto_add_new_groups", Encode.list (List.map Encode.int siteConfig.auto_add_new_groups) )
    , ( "sms_expiration_date", Encode.encodeMaybeDateOnly siteConfig.sms_expiration_date )
    , ( "sms_rolling_expiration_days", Encode.encodeMaybe Encode.int siteConfig.sms_rolling_expiration_days )
    , ( "slack_url", Encode.string siteConfig.slack_url )
    , ( "sync_elvanto", Encode.bool siteConfig.sync_elvanto )
    , ( "not_approved_msg", Encode.string siteConfig.not_approved_msg )
    , ( "email_host", Encode.encodeMaybe Encode.string siteConfig.email_host )
    , ( "email_port", Encode.encodeMaybe Encode.int siteConfig.email_port )
    , ( "email_username", Encode.encodeMaybe Encode.string siteConfig.email_username )
    , ( "email_password", Encode.encodeMaybe Encode.string siteConfig.email_password )
    , ( "email_from", Encode.encodeMaybe Encode.string siteConfig.email_from )
    , ( "twilio_from_num", Encode.encodeMaybe Encode.string siteConfig.twilio_from_num )
    , ( "twilio_sending_cost", Encode.encodeMaybe Encode.float siteConfig.twilio_sending_cost )
    , ( "twilio_auth_token", Encode.encodeMaybe Encode.string siteConfig.twilio_auth_token )
    , ( "twilio_account_sid", Encode.encodeMaybe Encode.string siteConfig.twilio_account_sid )
    ]



-- View


type alias Messages msg =
    { form : InputMsg -> msg
    , postForm : msg
    }


view : Messages msg -> RL.RemoteList RecipientGroup -> Model -> Html msg
view msgs groups { form } =
    F.form
        form
        (fieldsHelp msgs groups)
        msgs.postForm
        F.submitButton


debugHelpText : Html msg
debugHelpText =
    Html.p []
        [ Html.text "You can test these settings "
        , Html.a [ A.href "/config/debug/", A.target "_blank" ] [ Html.text "here" ]
        , Html.text "."
        ]


fieldsHelp : Messages msg -> RL.RemoteList RecipientGroup -> F.Item SiteConfigModel -> DirtyState -> List (F.FormItem msg)
fieldsHelp msgs groups itemState tmpState =
    [ F.FieldGroup
        { defaultFieldGroupConfig
            | header = Just "Twilio Settings"
            , sideBySide = Just 2
            , helpText = Just <| debugHelpText
        }
        [ F.Field meta.twilio_from_num (twilioFromNumField msgs itemState)
        , F.Field meta.twilio_sending_cost (twilioSendCostField msgs itemState tmpState)
        , F.Field meta.twilio_account_sid (twilioAccountSidField msgs itemState)
        , F.Field meta.twilio_auth_token (twilioAuthTokenField msgs itemState)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Site Settings" }
        [ F.Field meta.site_name (siteNameField msgs itemState)
        , F.Field meta.disable_email_login_form (emailLoginField msgs itemState)
        , F.Field meta.not_approved_msg (notAppField msgs itemState)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "SMS Settings" }
        [ F.Field meta.sms_char_limit (smsLimitField msgs itemState tmpState)
        , F.Field meta.default_number_prefix (defaultPrefixField msgs itemState)
        , F.Field meta.disable_all_replies (allRepliesField msgs itemState)
        , F.Field meta.auto_add_new_groups (autoNewGroupsField msgs groups itemState tmpState)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "SMS Expiration", sideBySide = Just 2 }
        [ F.Field meta.sms_expiration_date (smsExpirationDateField msgs itemState tmpState)
        , F.Field meta.sms_rolling_expiration_days (smsRollingExpireField msgs itemState tmpState)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Notification Settings" }
        [ F.Field meta.office_email (officeEmailField msgs itemState)
        , F.Field meta.slack_url (slackField msgs itemState)
        ]
    , F.FieldGroup
        { defaultFieldGroupConfig
            | header = Just "Sending Email Settings"
            , sideBySide = Just 3
            , helpText = Just <| debugHelpText
        }
        [ F.Field meta.email_host (emailHostField msgs itemState)
        , F.Field meta.email_port (emailPortField msgs itemState tmpState)
        , F.Field meta.email_username (emailUserField msgs itemState)
        , F.Field meta.email_password (emailPassField msgs itemState)
        , F.Field meta.email_from (emailFromField msgs itemState)
        ]
    , F.FieldGroup { defaultFieldGroupConfig | header = Just "Sync Settings" }
        [ F.Field meta.sync_elvanto (syncElvField msgs itemState)
        ]
    ]


twilioFromNumField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
twilioFromNumField msgs item =
    F.simpleTextField
        { getValue = .twilio_from_num >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateTwilioFromNum
        }


twilioSendCostField : Messages msg -> F.Item SiteConfigModel -> DirtyState -> (F.FieldMeta -> List (Html msg))
twilioSendCostField msgs item tmpState =
    F.simpleFloatField
        { getValue = .twilio_sending_cost
        , item = item
        , tmpState = tmpState.twilio_sending_cost
        , onInput = msgs.form << UpdateTwilioSendCost
        }


twilioAuthTokenField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
twilioAuthTokenField msgs item =
    F.simpleTextField
        { getValue = .twilio_auth_token >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateTwilioAuthToken
        }


twilioAccountSidField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
twilioAccountSidField msgs item =
    F.simpleTextField
        { getValue = .twilio_account_sid >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateTwilioSid
        }


siteNameField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
siteNameField msgs item =
    F.simpleTextField
        { getValue = .site_name
        , item = item
        , onInput = msgs.form << UpdateSiteNameField
        }


smsLimitField : Messages msg -> F.Item SiteConfigModel -> DirtyState -> (F.FieldMeta -> List (Html msg))
smsLimitField msgs item tmpState =
    F.simpleIntField
        { getValue = Just << .sms_char_limit
        , item = item
        , tmpState = tmpState.sms_char_limit
        , onInput = msgs.form << UpdateSmsCharLimitField
        }


smsRollingExpireField : Messages msg -> F.Item SiteConfigModel -> DirtyState -> (F.FieldMeta -> List (Html msg))
smsRollingExpireField msgs item tmpState =
    F.simpleIntField
        { getValue = .sms_rolling_expiration_days
        , item = item
        , tmpState = tmpState.sms_rolling_expiration_days
        , onInput = msgs.form << UpdateRollingExpiration
        }


defaultPrefixField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
defaultPrefixField msgs item =
    F.simpleTextField
        { getValue = .default_number_prefix
        , item = item
        , onInput = msgs.form << UpdateDefaultPrefixField
        }


allRepliesField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
allRepliesField msgs item =
    F.checkboxField
        .disable_all_replies
        item
        (msgs.form UpdateDisableRepliesField)


emailLoginField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
emailLoginField msgs item =
    F.checkboxField
        .disable_email_login_form
        item
        (msgs.form UpdateDisableLoginEmailField)


officeEmailField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
officeEmailField msgs item =
    F.simpleTextField
        { getValue = .office_email
        , item = item
        , onInput = msgs.form << UpdateOfficeEmailField
        }


autoNewGroupsField : Messages msg -> RL.RemoteList RecipientGroup -> F.Item SiteConfigModel -> DirtyState -> (F.FieldMeta -> List (Html msg))
autoNewGroupsField msgs groups item tmpState =
    F.multiSelectField
        { items = groups
        , getPks = .auto_add_new_groups
        , item = item
        , filter = tmpState.groupsFilter
        , filterMsg = msgs.form << UpdateGroupsFilter
        , itemView = groupView msgs
        , selectedView = groupLabelView msgs
        }


smsExpirationDateField : Messages msg -> F.Item SiteConfigModel -> DirtyState -> (F.FieldMeta -> List (Html msg))
smsExpirationDateField msgs item tmpState =
    F.dateField
        (updateExpDate msgs)
        tmpState.datePickerSmsExpiredState
        .sms_expiration_date
        item


updateExpDate : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateExpDate msgs state maybeDate =
    msgs.form <| UpdateSmsExpiredDate state maybeDate


groupLabelView : Messages msg -> List Int -> RecipientGroup -> Html msg
groupLabelView msgs _ group =
    F.multiSelectItemLabelHelper
        .name
        (msgs.form <| UpdateAutoAddGroupsField group.pk)
        group


groupView : Messages msg -> List Int -> RecipientGroup -> Html msg
groupView msgs selectedPks group =
    F.multiSelectItemHelper
        { itemToStr = .name
        , selectedPks = selectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.form << UpdateAutoAddGroupsField
        , itemToId = .pk >> toString >> (++) "group"
        }
        group


slackField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
slackField msgs item =
    F.simpleTextField
        { getValue = .slack_url
        , item = item
        , onInput = msgs.form << UpdateSlackUrlField
        }


syncElvField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
syncElvField msgs item =
    F.checkboxField
        .sync_elvanto
        item
        (msgs.form UpdateSyncElvantoField)


notAppField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
notAppField msgs item =
    F.longTextField
        10
        { getValue = .not_approved_msg
        , item = item
        , onInput = msgs.form << UpdateNotApprovedField
        }


emailHostField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
emailHostField msgs item =
    F.simpleTextField
        { getValue = .email_host >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateEmailHostField
        }


emailPortField : Messages msg -> F.Item SiteConfigModel -> DirtyState -> (F.FieldMeta -> List (Html msg))
emailPortField msgs item tmpState =
    F.simpleIntField
        { getValue = .email_port
        , item = item
        , tmpState = tmpState.email_port
        , onInput = msgs.form << UpdateEmailPortField
        }


emailUserField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
emailUserField msgs item =
    F.simpleTextField
        { getValue = .email_username >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateEmailUserField
        }


emailPassField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
emailPassField msgs item =
    F.simpleTextField
        { getValue = .email_password >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateEmailPassField
        }


emailFromField : Messages msg -> F.Item SiteConfigModel -> (F.FieldMeta -> List (Html msg))
emailFromField msgs item =
    F.simpleTextField
        { getValue = .email_from >> Maybe.withDefault ""
        , item = item
        , onInput = msgs.form << UpdateEmailFromField
        }
