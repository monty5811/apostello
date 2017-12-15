module Pages.Forms.SiteConfig exposing (Model, Msg(..), decodeModel, update, view)

import Data exposing (RecipientGroup)
import Date
import DateTimePicker
import FilteringTable exposing (textToRegex)
import Forms.Model exposing (Field, FieldMeta, FormItem(FieldGroup), FormStatus, defaultFieldGroupConfig)
import Forms.View as FV
import Helpers exposing (toggleSelectedPk)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Pages.Forms.Meta.SiteConfig exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Rocket exposing ((=>))


type alias Model =
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


decodeModel : Decode.Decoder Model
decodeModel =
    decode Model
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
    = UpdateTwilioFromNum Model String
    | UpdateTwilioSid Model String
    | UpdateTwilioAuthToken Model String
    | UpdateTwilioSendCost Model String
    | UpdateSiteNameField Model String
    | UpdateSmsCharLimitField Model String
    | UpdateDefaultPrefixField Model String
    | UpdateDisableRepliesField Model
    | UpdateDisableLoginEmailField Model
    | UpdateOfficeEmailField Model String
    | UpdateAutoAddGroupsField Model Int
    | UpdateSmsExpiredDate Model DateTimePicker.State (Maybe Date.Date)
    | UpdateRollingExpiration Model String
    | UpdateSlackUrlField Model String
    | UpdateSyncElvantoField Model
    | UpdateNotApprovedField Model String
    | UpdateEmailHostField Model String
    | UpdateEmailPortField Model String
    | UpdateEmailUserField Model String
    | UpdateEmailPassField Model String
    | UpdateEmailFromField Model String
    | UpdateGroupsFilter Model String


update : Msg -> Model
update msg =
    case msg of
        UpdateTwilioFromNum model text ->
            { model | twilio_from_num = Just text }

        UpdateTwilioSid model text ->
            { model | twilio_account_sid = Just text }

        UpdateTwilioAuthToken model text ->
            { model | twilio_auth_token = Just text }

        UpdateTwilioSendCost model text ->
            case String.toFloat text of
                Ok num ->
                    { model | twilio_sending_cost = Just num }

                Err _ ->
                    model

        UpdateSiteNameField model text ->
            { model | site_name = text }

        UpdateSmsCharLimitField model text ->
            case String.toInt text of
                Ok num ->
                    { model | sms_char_limit = num }

                Err _ ->
                    model

        UpdateDefaultPrefixField model text ->
            { model | default_number_prefix = text }

        UpdateDisableRepliesField model ->
            { model | disable_all_replies = not model.disable_all_replies }

        UpdateDisableLoginEmailField model ->
            { model | disable_email_login_form = not model.disable_email_login_form }

        UpdateOfficeEmailField model text ->
            { model | office_email = text }

        UpdateAutoAddGroupsField model pk ->
            { model | auto_add_new_groups = toggleSelectedPk pk model.auto_add_new_groups }

        UpdateSmsExpiredDate model state maybeDate ->
            { model | sms_expiration_date = maybeDate, datePickerSmsExpiredState = state }

        UpdateRollingExpiration model maybeNum ->
            let
                num =
                    maybeNum
                        |> String.toInt
                        |> Result.toMaybe
            in
            { model | sms_rolling_expiration_days = num }

        UpdateSlackUrlField model text ->
            { model | slack_url = text }

        UpdateSyncElvantoField model ->
            { model | sync_elvanto = not model.sync_elvanto }

        UpdateNotApprovedField model text ->
            { model | not_approved_msg = text }

        UpdateEmailHostField model text ->
            { model | email_host = Just text }

        UpdateEmailPortField model text ->
            case String.toInt text of
                Ok num ->
                    { model | email_port = Just num }

                Err _ ->
                    model

        UpdateEmailUserField model text ->
            { model | email_username = Just text }

        UpdateEmailPassField model text ->
            { model | email_password = Just text }

        UpdateEmailFromField model text ->
            { model | email_from = Just text }

        UpdateGroupsFilter model text ->
            { model | groupsFilter = textToRegex text }



-- View


type alias Messages msg =
    { form : Msg -> msg
    , postForm : msg
    , noop : msg
    }


view : Messages msg -> RL.RemoteList RecipientGroup -> Maybe Model -> FormStatus -> Html msg
view msgs groups maybeModel status =
    case maybeModel of
        Nothing ->
            loader

        Just model ->
            let
                fields =
                    fieldsHelp msgs groups model
            in
            FV.form status
                fields
                msgs.postForm
                (FV.submitButton (Just model) False)


debugHelpText : Html msg
debugHelpText =
    Html.p []
        [ Html.text "You can test these settings "
        , Html.a [ A.href "/config/debug/", A.target "_blank" ] [ Html.text "here" ]
        , Html.text "."
        ]


fieldsHelp : Messages msg -> RL.RemoteList RecipientGroup -> Model -> List (FormItem msg)
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
            , sideBySide = Just 2
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


twilioFromNumField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioFromNumField msgs model =
    FV.simpleTextField
        model.twilio_from_num
        (msgs.form << UpdateTwilioFromNum model)


twilioSendCostField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioSendCostField msgs model =
    FV.simpleFloatField
        model.twilio_sending_cost
        (msgs.form << UpdateTwilioSendCost model)


twilioAuthTokenField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioAuthTokenField msgs model =
    FV.simpleTextField
        model.twilio_auth_token
        (msgs.form << UpdateTwilioAuthToken model)


twilioAccountSidField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioAccountSidField msgs model =
    FV.simpleTextField
        model.twilio_account_sid
        (msgs.form << UpdateTwilioSid model)


siteNameField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
siteNameField msgs model =
    FV.simpleTextField
        (Just model.site_name)
        (msgs.form << UpdateSiteNameField model)


smsLimitField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
smsLimitField msgs model =
    FV.simpleIntField
        (Just model.sms_char_limit)
        (msgs.form << UpdateSmsCharLimitField model)


smsRollingExpireField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
smsRollingExpireField msgs model =
    FV.simpleIntField
        model.sms_rolling_expiration_days
        (msgs.form << UpdateRollingExpiration model)


defaultPrefixField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
defaultPrefixField msgs model =
    FV.simpleTextField
        (Just model.default_number_prefix)
        (msgs.form << UpdateDefaultPrefixField model)


allRepliesField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
allRepliesField msgs model =
    FV.checkboxField
        (Just model)
        .disable_all_replies
        (msgOrNope msgs (msgs.form << UpdateDisableRepliesField))


msgOrNope : Messages msg -> (a -> msg) -> Maybe a -> msg
msgOrNope msgs msg maybeRec =
    case maybeRec of
        Nothing ->
            msgs.noop

        Just rec ->
            msg rec


emailLoginField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailLoginField msgs model =
    FV.checkboxField
        (Just model)
        .disable_email_login_form
        (msgOrNope msgs (msgs.form << UpdateDisableLoginEmailField))


officeEmailField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
officeEmailField msgs model =
    FV.simpleTextField
        (Just model.office_email)
        (msgs.form << UpdateOfficeEmailField model)


autoNewGroupsField : Messages msg -> RL.RemoteList RecipientGroup -> Model -> (FieldMeta -> List (Html msg))
autoNewGroupsField msgs groups model =
    FV.multiSelectField
        (FV.MultiSelectField
            groups
            (Just model.auto_add_new_groups)
            (Just model.auto_add_new_groups)
            model.groupsFilter
            (msgs.form << UpdateGroupsFilter model)
            (groupView msgs model)
            (groupLabelView msgs model)
        )


smsExpirationDateField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
smsExpirationDateField msgs model =
    FV.dateField (updateExpDate msgs model) model.datePickerSmsExpiredState model.sms_expiration_date


updateExpDate : Messages msg -> Model -> DateTimePicker.State -> Maybe Date.Date -> msg
updateExpDate msgs model state maybeDate =
    msgs.form <| UpdateSmsExpiredDate model state maybeDate


groupLabelView : Messages msg -> Model -> Maybe (List Int) -> RecipientGroup -> Html msg
groupLabelView msgs model maybePks group =
    Html.div
        [ A.class "badge"
        , A.style [ "user-select" => "none" ]
        , E.onClick <| msgs.form <| UpdateAutoAddGroupsField model group.pk
        ]
        [ Html.text group.name ]


groupView : Messages msg -> Model -> Maybe (List Int) -> RecipientGroup -> Html msg
groupView msgs model maybeSelectedPks group =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ A.class "item", E.onClick <| msgs.form <| UpdateAutoAddGroupsField model group.pk ]
        [ ( toString group.pk, groupViewHelper selectedPks group ) ]


groupViewHelper : List Int -> RecipientGroup -> Html msg
groupViewHelper selectedPks group =
    Html.div [ A.style [ "color" => "#000" ] ]
        [ FV.selectedIcon selectedPks group
        , Html.text group.name
        ]


slackField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
slackField msgs model =
    FV.simpleTextField
        (Just model.slack_url)
        (msgs.form << UpdateSlackUrlField model)


syncElvField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
syncElvField msgs model =
    FV.checkboxField
        (Just model)
        .sync_elvanto
        (msgOrNope msgs (msgs.form << UpdateSyncElvantoField))


notAppField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
notAppField msgs model =
    FV.longTextField
        10
        (Just model.not_approved_msg)
        (msgs.form << UpdateNotApprovedField model)


emailHostField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailHostField msgs model =
    FV.simpleTextField
        model.email_host
        (msgs.form << UpdateEmailHostField model)


emailPortField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailPortField msgs model =
    FV.simpleIntField
        model.email_port
        (msgs.form << UpdateEmailPortField model)


emailUserField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailUserField msgs model =
    FV.simpleTextField
        model.email_username
        (msgs.form << UpdateEmailUserField model)


emailPassField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailPassField msgs model =
    FV.simpleTextField
        model.email_password
        (msgs.form << UpdateEmailPassField model)


emailFromField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailFromField msgs model =
    FV.simpleTextField
        model.email_from
        (msgs.form << UpdateEmailFromField model)
