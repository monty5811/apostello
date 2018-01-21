module Pages.Forms.SiteConfig exposing (Model, Msg(..), decodeModel, init, update, view)

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
import Http
import Json.Decode as Decode
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline exposing (decode, hardcoded, required)
import Pages.Forms.Meta.SiteConfig exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Urls


init : Cmd Msg
init =
    Http.get Urls.api_site_config decodeModel
        |> Http.send ReceiveInitialData


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
    | ReceiveInitialData (Result Http.Error Model)


update : Msg -> Maybe Model -> ( Maybe Model, Cmd Msg )
update msg maybeModel =
    case msg of
        ReceiveInitialData (Ok initialModel) ->
            ( Just initialModel
            , DateTimePicker.initialCmd (initSmsExpireDate initialModel) initialModel.datePickerSmsExpiredState
            )

        _ ->
            ( Maybe.andThen (updateHelp msg) maybeModel, Cmd.none )


initSmsExpireDate : Model -> DateTimePicker.State -> Maybe Date.Date -> Msg
initSmsExpireDate model datePickerSmsExpiredState maybeDate =
    UpdateSmsExpiredDate datePickerSmsExpiredState model.sms_expiration_date


updateHelp : Msg -> Model -> Maybe Model
updateHelp msg model =
    case msg of
        ReceiveInitialData (Ok initialModel) ->
            Just initialModel

        ReceiveInitialData (Err _) ->
            Nothing

        UpdateTwilioFromNum text ->
            Just { model | twilio_from_num = Just text }

        UpdateTwilioSid text ->
            Just { model | twilio_account_sid = Just text }

        UpdateTwilioAuthToken text ->
            Just { model | twilio_auth_token = Just text }

        UpdateTwilioSendCost text ->
            case String.toFloat text of
                Ok num ->
                    Just { model | twilio_sending_cost = Just num }

                Err _ ->
                    Just model

        UpdateSiteNameField text ->
            Just { model | site_name = text }

        UpdateSmsCharLimitField text ->
            case String.toInt text of
                Ok num ->
                    Just { model | sms_char_limit = num }

                Err _ ->
                    Just model

        UpdateDefaultPrefixField text ->
            Just { model | default_number_prefix = text }

        UpdateDisableRepliesField ->
            Just { model | disable_all_replies = not model.disable_all_replies }

        UpdateDisableLoginEmailField ->
            Just { model | disable_email_login_form = not model.disable_email_login_form }

        UpdateOfficeEmailField text ->
            Just { model | office_email = text }

        UpdateAutoAddGroupsField pk ->
            Just { model | auto_add_new_groups = toggleSelectedPk pk model.auto_add_new_groups }

        UpdateSmsExpiredDate state maybeDate ->
            Just { model | sms_expiration_date = maybeDate, datePickerSmsExpiredState = state }

        UpdateRollingExpiration maybeNum ->
            let
                num =
                    maybeNum
                        |> String.toInt
                        |> Result.toMaybe
            in
            Just { model | sms_rolling_expiration_days = num }

        UpdateSlackUrlField text ->
            Just { model | slack_url = text }

        UpdateSyncElvantoField ->
            Just { model | sync_elvanto = not model.sync_elvanto }

        UpdateNotApprovedField text ->
            Just { model | not_approved_msg = text }

        UpdateEmailHostField text ->
            Just { model | email_host = Just text }

        UpdateEmailPortField text ->
            case String.toInt text of
                Ok num ->
                    Just { model | email_port = Just num }

                Err _ ->
                    Just model

        UpdateEmailUserField text ->
            Just { model | email_username = Just text }

        UpdateEmailPassField text ->
            Just { model | email_password = Just text }

        UpdateEmailFromField text ->
            Just { model | email_from = Just text }

        UpdateGroupsFilter text ->
            Just { model | groupsFilter = textToRegex text }



-- View


type alias Messages msg =
    { form : Msg -> msg
    , postForm : msg
    }


view : Messages msg -> RL.RemoteList RecipientGroup -> Maybe Model -> FormStatus -> Html msg
view msgs groups maybeModel status =
    case maybeModel of
        Nothing ->
            loader

        Just model ->
            FV.form status
                (fieldsHelp msgs groups model)
                msgs.postForm
                (FV.submitButton maybeModel False)


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
        (msgs.form << UpdateTwilioFromNum)


twilioSendCostField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioSendCostField msgs model =
    FV.simpleFloatField
        model.twilio_sending_cost
        (msgs.form << UpdateTwilioSendCost)


twilioAuthTokenField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioAuthTokenField msgs model =
    FV.simpleTextField
        model.twilio_auth_token
        (msgs.form << UpdateTwilioAuthToken)


twilioAccountSidField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
twilioAccountSidField msgs model =
    FV.simpleTextField
        model.twilio_account_sid
        (msgs.form << UpdateTwilioSid)


siteNameField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
siteNameField msgs model =
    FV.simpleTextField
        (Just model.site_name)
        (msgs.form << UpdateSiteNameField)


smsLimitField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
smsLimitField msgs model =
    FV.simpleIntField
        (Just model.sms_char_limit)
        (msgs.form << UpdateSmsCharLimitField)


smsRollingExpireField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
smsRollingExpireField msgs model =
    FV.simpleIntField
        model.sms_rolling_expiration_days
        (msgs.form << UpdateRollingExpiration)


defaultPrefixField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
defaultPrefixField msgs model =
    FV.simpleTextField
        (Just model.default_number_prefix)
        (msgs.form << UpdateDefaultPrefixField)


allRepliesField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
allRepliesField msgs model =
    FV.checkboxField
        (Just model)
        .disable_all_replies
        (\_ -> msgs.form UpdateDisableRepliesField)


emailLoginField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailLoginField msgs model =
    FV.checkboxField
        (Just model)
        .disable_email_login_form
        (\_ -> msgs.form UpdateDisableLoginEmailField)


officeEmailField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
officeEmailField msgs model =
    FV.simpleTextField
        (Just model.office_email)
        (msgs.form << UpdateOfficeEmailField)


autoNewGroupsField : Messages msg -> RL.RemoteList RecipientGroup -> Model -> (FieldMeta -> List (Html msg))
autoNewGroupsField msgs groups model =
    FV.multiSelectField
        (FV.MultiSelectField
            groups
            (Just model.auto_add_new_groups)
            (Just model.auto_add_new_groups)
            model.groupsFilter
            (msgs.form << UpdateGroupsFilter)
            (groupView msgs)
            (groupLabelView msgs)
        )


smsExpirationDateField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
smsExpirationDateField msgs model =
    FV.dateField (updateExpDate msgs) model.datePickerSmsExpiredState model.sms_expiration_date


updateExpDate : Messages msg -> DateTimePicker.State -> Maybe Date.Date -> msg
updateExpDate msgs state maybeDate =
    msgs.form <| UpdateSmsExpiredDate state maybeDate


groupLabelView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupLabelView msgs maybePks group =
    Html.div
        [ A.class "badge"
        , A.style [ ( "user-select", "none" ) ]
        , E.onClick <| msgs.form <| UpdateAutoAddGroupsField group.pk
        ]
        [ Html.text group.name ]


groupView : Messages msg -> Maybe (List Int) -> RecipientGroup -> Html msg
groupView msgs maybeSelectedPks group =
    let
        selectedPks =
            case maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ A.class "item", E.onClick <| msgs.form <| UpdateAutoAddGroupsField group.pk ]
        [ ( toString group.pk, groupViewHelper selectedPks group ) ]


groupViewHelper : List Int -> RecipientGroup -> Html msg
groupViewHelper selectedPks group =
    Html.div [ A.style [ ( "color", "#000" ) ] ]
        [ FV.selectedIcon selectedPks group
        , Html.text group.name
        ]


slackField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
slackField msgs model =
    FV.simpleTextField
        (Just model.slack_url)
        (msgs.form << UpdateSlackUrlField)


syncElvField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
syncElvField msgs model =
    FV.checkboxField
        (Just model)
        .sync_elvanto
        (\_ -> msgs.form UpdateSyncElvantoField)


notAppField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
notAppField msgs model =
    FV.longTextField
        10
        (Just model.not_approved_msg)
        (msgs.form << UpdateNotApprovedField)


emailHostField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailHostField msgs model =
    FV.simpleTextField
        model.email_host
        (msgs.form << UpdateEmailHostField)


emailPortField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailPortField msgs model =
    FV.simpleIntField
        model.email_port
        (msgs.form << UpdateEmailPortField)


emailUserField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailUserField msgs model =
    FV.simpleTextField
        model.email_username
        (msgs.form << UpdateEmailUserField)


emailPassField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailPassField msgs model =
    FV.simpleTextField
        model.email_password
        (msgs.form << UpdateEmailPassField)


emailFromField : Messages msg -> Model -> (FieldMeta -> List (Html msg))
emailFromField msgs model =
    FV.simpleTextField
        model.email_from
        (msgs.form << UpdateEmailFromField)
