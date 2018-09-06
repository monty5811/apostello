module Pages.Forms.SiteConfig
    exposing
        ( FModel
        , Model
        , Msg(..)
        , decodeFModel
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
import Form as F exposing (Field, FieldMeta, FormItem(FieldGroup), FormStatus(NoAction), defaultFieldGroupConfig)
import Helpers exposing (toggleSelectedPk)
import Html exposing (Html)
import Html.Attributes as A
import Http
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Json.Encode as Encode
import Pages.Forms.Meta.SiteConfig exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Urls


init : Cmd Msg
init =
    Http.get Urls.api_site_config decodeFModel
        |> Http.send ReceiveInitialData


type alias Model =
    { fModel : Maybe FModel
    , formStatus : FormStatus
    }


initialModel : Model
initialModel =
    { fModel = Nothing
    , formStatus = NoAction
    }


type alias FModel =
    { site_name : String
    , sms_char_limit : Int
    , default_number_prefix : String
    , disable_all_replies : Bool
    , disable_email_login_form : Bool
    , office_email : String
    , auto_add_new_groups : List Int
    , sms_expiration_date : Maybe Date.Date
    , datePickerSmsExpiredState : DateTimePicker.State
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
    , groupsFilter : Regex.Regex
    }


decodeFModel : Decode.Decoder FModel
decodeFModel =
    decode FModel
        |> required "site_name" Decode.string
        |> required "sms_char_limit" Decode.int
        |> required "default_number_prefix" Decode.string
        |> required "disable_all_replies" Decode.bool
        |> required "disable_email_login_form" Decode.bool
        |> required "office_email" Decode.string
        |> required "auto_add_new_groups" (Decode.list Decode.int)
        |> required "sms_expiration_date" (Decode.maybe date)
        |> hardcoded DateTimePicker.initialState
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
        |> hardcoded (Regex.regex "")



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ReceiveInitialData (Result Http.Error FModel)


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
        ReceiveInitialData (Ok initialModel) ->
            F.UpdateResp
                { model | fModel = Just initialModel }
                (DateTimePicker.initialCmd (initSmsExpireDate initialModel) initialModel.datePickerSmsExpiredState)
                []
                Nothing

        ReceiveInitialData (Err _) ->
            F.UpdateResp
                model
                Cmd.none
                []
                Nothing

        InputMsg inputMsg ->
            F.UpdateResp
                { model | fModel = Maybe.map (updateInput inputMsg) model.fModel }
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postCmd props.csrftoken model.fModel)
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


initSmsExpireDate : FModel -> DateTimePicker.State -> Maybe Date.Date -> Msg
initSmsExpireDate model datePickerSmsExpiredState _ =
    InputMsg (UpdateSmsExpiredDate datePickerSmsExpiredState model.sms_expiration_date)


updateInput : InputMsg -> FModel -> FModel
updateInput msg model =
    case msg of
        UpdateTwilioFromNum text ->
            { model | twilio_from_num = Just text }

        UpdateTwilioSid text ->
            { model | twilio_account_sid = Just text }

        UpdateTwilioAuthToken text ->
            { model | twilio_auth_token = Just text }

        UpdateTwilioSendCost text ->
            case String.toFloat text of
                Ok num ->
                    { model | twilio_sending_cost = Just num }

                Err _ ->
                    model

        UpdateSiteNameField text ->
            { model | site_name = text }

        UpdateSmsCharLimitField text ->
            case String.toInt text of
                Ok num ->
                    { model | sms_char_limit = num }

                Err _ ->
                    model

        UpdateDefaultPrefixField text ->
            { model | default_number_prefix = text }

        UpdateDisableRepliesField ->
            { model | disable_all_replies = not model.disable_all_replies }

        UpdateDisableLoginEmailField ->
            { model | disable_email_login_form = not model.disable_email_login_form }

        UpdateOfficeEmailField text ->
            { model | office_email = text }

        UpdateAutoAddGroupsField pk ->
            { model | auto_add_new_groups = toggleSelectedPk pk model.auto_add_new_groups }

        UpdateSmsExpiredDate state maybeDate ->
            { model | sms_expiration_date = maybeDate, datePickerSmsExpiredState = state }

        UpdateRollingExpiration maybeNum ->
            let
                num =
                    maybeNum
                        |> String.toInt
                        |> Result.toMaybe
            in
            { model | sms_rolling_expiration_days = num }

        UpdateSlackUrlField text ->
            { model | slack_url = text }

        UpdateSyncElvantoField ->
            { model | sync_elvanto = not model.sync_elvanto }

        UpdateNotApprovedField text ->
            { model | not_approved_msg = text }

        UpdateEmailHostField text ->
            { model | email_host = Just text }

        UpdateEmailPortField text ->
            case String.toInt text of
                Ok num ->
                    { model | email_port = Just num }

                Err _ ->
                    model

        UpdateEmailUserField text ->
            { model | email_username = Just text }

        UpdateEmailPassField text ->
            { model | email_password = Just text }

        UpdateEmailFromField text ->
            { model | email_from = Just text }

        UpdateGroupsFilter text ->
            { model | groupsFilter = textToRegex text }


postCmd : DjangoSend.CSRFToken -> Maybe FModel -> Cmd Msg
postCmd csrf maybeModel =
    case maybeModel of
        Nothing ->
            Cmd.none

        Just model ->
            let
                body =
                    [ ( "site_name", Encode.string model.site_name )
                    , ( "sms_char_limit", Encode.int model.sms_char_limit )
                    , ( "default_number_prefix", Encode.string model.default_number_prefix )
                    , ( "disable_all_replies", Encode.bool model.disable_all_replies )
                    , ( "disable_email_login_form", Encode.bool model.disable_email_login_form )
                    , ( "office_email", Encode.string model.office_email )
                    , ( "auto_add_new_groups", Encode.list (List.map Encode.int model.auto_add_new_groups) )
                    , ( "sms_expiration_date", Encode.encodeMaybeDateOnly model.sms_expiration_date )
                    , ( "sms_rolling_expiration_days", Encode.encodeMaybe Encode.int model.sms_rolling_expiration_days )
                    , ( "slack_url", Encode.string model.slack_url )
                    , ( "sync_elvanto", Encode.bool model.sync_elvanto )
                    , ( "not_approved_msg", Encode.string model.not_approved_msg )
                    , ( "email_host", Encode.encodeMaybe Encode.string model.email_host )
                    , ( "email_port", Encode.encodeMaybe Encode.int model.email_port )
                    , ( "email_username", Encode.encodeMaybe Encode.string model.email_username )
                    , ( "email_password", Encode.encodeMaybe Encode.string model.email_password )
                    , ( "email_from", Encode.encodeMaybe Encode.string model.email_from )
                    , ( "twilio_from_num", Encode.encodeMaybe Encode.string model.twilio_from_num )
                    , ( "twilio_sending_cost", Encode.encodeMaybe Encode.float model.twilio_sending_cost )
                    , ( "twilio_auth_token", Encode.encodeMaybe Encode.string model.twilio_auth_token )
                    , ( "twilio_account_sid", Encode.encodeMaybe Encode.string model.twilio_account_sid )
                    ]
            in
            DjangoSend.rawPost csrf Urls.api_site_config body
                |> Http.send ReceiveFormResp



-- View


type alias Messages msg =
    { form : InputMsg -> msg
    , postForm : msg
    }


view : Messages msg -> RL.RemoteList RecipientGroup -> Model -> Html msg
view msgs groups { fModel, formStatus } =
    case fModel of
        Nothing ->
            loader

        Just model ->
            F.form
                formStatus
                (fieldsHelp msgs groups model)
                msgs.postForm
                (F.submitButton fModel)


debugHelpText : Html msg
debugHelpText =
    Html.p []
        [ Html.text "You can test these settings "
        , Html.a [ A.href "/config/debug/", A.target "_blank" ] [ Html.text "here" ]
        , Html.text "."
        ]


fieldsHelp : Messages msg -> RL.RemoteList RecipientGroup -> FModel -> List (FormItem msg)
fieldsHelp msgs groups model =
    [ FieldGroup
        { defaultFieldGroupConfig
            | header = Just "Twilio Settings"
            , sideBySide = Just 2
            , helpText = Just <| debugHelpText
        }
        [ Field meta.twilio_from_num (twilioFromNumField msgs model)
        , Field meta.twilio_sending_cost (twilioSendCostField msgs model)
        , Field meta.twilio_account_sid (twilioAccountSidField msgs model)
        , Field meta.twilio_auth_token (twilioAuthTokenField msgs model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "Site Settings" }
        [ Field meta.site_name (siteNameField msgs model)
        , Field meta.disable_email_login_form (emailLoginField msgs model)
        , Field meta.not_approved_msg (notAppField msgs model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "SMS Settings" }
        [ Field meta.sms_char_limit (smsLimitField msgs model)
        , Field meta.default_number_prefix (defaultPrefixField msgs model)
        , Field meta.disable_all_replies (allRepliesField msgs model)
        , Field meta.auto_add_new_groups (autoNewGroupsField msgs groups model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "SMS Expiration", sideBySide = Just 2 }
        [ Field meta.sms_expiration_date (smsExpirationDateField msgs model)
        , Field meta.sms_rolling_expiration_days (smsRollingExpireField msgs model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "Notification Settings" }
        [ Field meta.office_email (officeEmailField msgs model)
        , Field meta.slack_url (slackField msgs model)
        ]
    , FieldGroup
        { defaultFieldGroupConfig
            | header = Just "Sending Email Settings"
            , sideBySide = Just 3
            , helpText = Just <| debugHelpText
        }
        [ Field meta.email_host (emailHostField msgs model)
        , Field meta.email_port (emailPortField msgs model)
        , Field meta.email_username (emailUserField msgs model)
        , Field meta.email_password (emailPassField msgs model)
        , Field meta.email_from (emailFromField msgs model)
        ]
    , FieldGroup { defaultFieldGroupConfig | header = Just "Sync Settings" }
        [ Field meta.sync_elvanto (syncElvField msgs model)
        ]
    ]


twilioFromNumField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
twilioFromNumField msgs model =
    F.simpleTextField
        model.twilio_from_num
        (msgs.form << UpdateTwilioFromNum)


twilioSendCostField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
twilioSendCostField msgs model =
    F.simpleFloatField
        model.twilio_sending_cost
        (msgs.form << UpdateTwilioSendCost)


twilioAuthTokenField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
twilioAuthTokenField msgs model =
    F.simpleTextField
        model.twilio_auth_token
        (msgs.form << UpdateTwilioAuthToken)


twilioAccountSidField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
twilioAccountSidField msgs model =
    F.simpleTextField
        model.twilio_account_sid
        (msgs.form << UpdateTwilioSid)


siteNameField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
siteNameField msgs model =
    F.simpleTextField
        (Just model.site_name)
        (msgs.form << UpdateSiteNameField)


smsLimitField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
smsLimitField msgs model =
    F.simpleIntField
        (Just model.sms_char_limit)
        (msgs.form << UpdateSmsCharLimitField)


smsRollingExpireField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
smsRollingExpireField msgs model =
    F.simpleIntField
        model.sms_rolling_expiration_days
        (msgs.form << UpdateRollingExpiration)


defaultPrefixField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
defaultPrefixField msgs model =
    F.simpleTextField
        (Just model.default_number_prefix)
        (msgs.form << UpdateDefaultPrefixField)


allRepliesField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
allRepliesField msgs model =
    F.checkboxField
        (Just model)
        .disable_all_replies
        (\_ -> msgs.form UpdateDisableRepliesField)


emailLoginField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
emailLoginField msgs model =
    F.checkboxField
        (Just model)
        .disable_email_login_form
        (\_ -> msgs.form UpdateDisableLoginEmailField)


officeEmailField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
officeEmailField msgs model =
    F.simpleTextField
        (Just model.office_email)
        (msgs.form << UpdateOfficeEmailField)


autoNewGroupsField : Messages msg -> RL.RemoteList RecipientGroup -> FModel -> (FieldMeta -> List (Html msg))
autoNewGroupsField msgs groups model =
    F.multiSelectField
        (F.MultiSelectField
            groups
            (Just model.auto_add_new_groups)
            (Just model.auto_add_new_groups)
            model.groupsFilter
            (msgs.form << UpdateGroupsFilter)
            (groupView msgs)
            (groupLabelView msgs)
        )


smsExpirationDateField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
smsExpirationDateField msgs model =
    F.dateField (updateExpDate msgs) model.datePickerSmsExpiredState model.sms_expiration_date


updateExpDate : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateExpDate msgs state maybeDate =
    msgs.form <| UpdateSmsExpiredDate state maybeDate


groupLabelView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupLabelView msgs _ group =
    F.multiSelectItemLabelHelper
        .name
        (msgs.form <| UpdateAutoAddGroupsField group.pk)
        group


groupView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupView msgs maybeSelectedPks group =
    F.multiSelectItemHelper
        { itemToStr = .name
        , maybeSelectedPks = maybeSelectedPks
        , itemToKey = .pk >> toString
        , toggleMsg = msgs.form << UpdateAutoAddGroupsField
        , itemToId = .pk >> toString >> (++) "group"
        }
        group


slackField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
slackField msgs model =
    F.simpleTextField
        (Just model.slack_url)
        (msgs.form << UpdateSlackUrlField)


syncElvField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
syncElvField msgs model =
    F.checkboxField
        (Just model)
        .sync_elvanto
        (\_ -> msgs.form UpdateSyncElvantoField)


notAppField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
notAppField msgs model =
    F.longTextField
        10
        (Just model.not_approved_msg)
        (msgs.form << UpdateNotApprovedField)


emailHostField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
emailHostField msgs model =
    F.simpleTextField
        model.email_host
        (msgs.form << UpdateEmailHostField)


emailPortField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
emailPortField msgs model =
    F.simpleIntField
        model.email_port
        (msgs.form << UpdateEmailPortField)


emailUserField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
emailUserField msgs model =
    F.simpleTextField
        model.email_username
        (msgs.form << UpdateEmailUserField)


emailPassField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
emailPassField msgs model =
    F.simpleTextField
        model.email_password
        (msgs.form << UpdateEmailPassField)


emailFromField : Messages msg -> FModel -> (FieldMeta -> List (Html msg))
emailFromField msgs model =
    F.simpleTextField
        model.email_from
        (msgs.form << UpdateEmailFromField)
