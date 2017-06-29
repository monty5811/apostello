module Forms.DatePickers exposing (initDateTimePickers)

import Date
import DateTimePicker
import Messages exposing (..)
import Models exposing (Model)
import Pages as P
import Pages.Forms.Keyword.Messages as KFM
import Pages.Forms.SendAdhoc.Messages as SAM
import Pages.Forms.SendGroup.Messages as SGM
import Pages.Forms.SiteConfig.Messages as SCM
import Pages.Forms.SiteConfig.Model exposing (SiteConfigFormModel)


initDateTimePickers : ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
initDateTimePickers ( model, msgs ) =
    ( model, msgs ++ initDateTimePickersHelp model.page )


initDateTimePickersHelp : P.Page -> List (Cmd Msg)
initDateTimePickersHelp page =
    case page of
        P.KeywordForm model _ ->
            [ DateTimePicker.initialCmd initActTime model.datePickerActState
            , DateTimePicker.initialCmd initDeactTime model.datePickerDeactState
            ]

        P.SendAdhoc model ->
            [ DateTimePicker.initialCmd initSendAdhocDate model.datePickerState ]

        P.SendGroup model ->
            [ DateTimePicker.initialCmd initSendGroupDate model.datePickerState ]

        P.SiteConfigForm maybeModel ->
            case maybeModel of
                Just model ->
                    [ DateTimePicker.initialCmd (initSmsExpireDate model) model.datePickerSmsExpiredState ]

                Nothing ->
                    []

        _ ->
            []


initActTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initActTime state maybeDate =
    FormMsg <| KeywordFormMsg <| KFM.UpdateActivateTime state maybeDate


initDeactTime : DateTimePicker.State -> Maybe Date.Date -> Msg
initDeactTime state maybeDate =
    FormMsg <| KeywordFormMsg <| KFM.UpdateDeactivateTime state maybeDate


initSendAdhocDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendAdhocDate state maybeDate =
    FormMsg <| SendAdhocMsg <| SAM.UpdateDate state maybeDate


initSendGroupDate : DateTimePicker.State -> Maybe Date.Date -> Msg
initSendGroupDate state maybeDate =
    FormMsg <| SendGroupMsg <| SGM.UpdateSGDate state maybeDate


initSmsExpireDate : SiteConfigFormModel -> DateTimePicker.State -> Maybe Date.Date -> Msg
initSmsExpireDate model datePickerSmsExpiredState maybeDate =
    FormMsg <| SiteConfigFormMsg <| SCM.UpdateSmsExpiredDate model datePickerSmsExpiredState model.sms_expiration_date
