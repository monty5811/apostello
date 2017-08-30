module Forms.View exposing (..)

import Date
import Date.Format
import DateTimePicker
import DateTimePicker.Config
import Dict
import FilteringTable exposing (filterInput, filterRecord)
import Forms.Model exposing (..)
import Html exposing (Html, button, div, i, input, label, text, textarea)
import Html.Attributes as A
import Html.Events as E exposing (onInput)
import Messages exposing (Msg)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Rocket exposing ((=>))
import Round


form : FormStatus -> List FormItem -> Msg -> Html Msg -> Html Msg
form formStatus items submitMsg button_ =
    case formStatus of
        InProgress ->
            loader

        _ ->
            Html.form [ E.onSubmit submitMsg ] <|
                renderFormError formStatus
                    ++ List.map (renderItem <| formErrors formStatus) items
                    ++ [ button_ ]


renderFormError : FormStatus -> List (Html Msg)
renderFormError status =
    case status of
        Failed errors ->
            case Dict.get "__all__" errors of
                Nothing ->
                    []

                Just e ->
                    List.map fieldMessage e

        _ ->
            []


renderItem : FormErrors -> FormItem -> Html Msg
renderItem errorDict item =
    case item of
        FormField field ->
            renderField errorDict field

        FormHeader header ->
            Html.h4 [ A.class "" ] [ Html.text header ]

        FieldGroup config fields ->
            fieldGroupHelp config <|
                List.map (renderField errorDict) fields


fieldGroupHelp : FieldGroupConfig -> List (Html Msg) -> Html Msg
fieldGroupHelp config fields =
    fields
        |> addSideBySide config.sideBySide
        |> addHeader config.header
        |> addSegment


addSideBySide : Bool -> List (Html Msg) -> List (Html Msg)
addSideBySide add fields =
    if add then
        [ div
            [ A.style
                [ "display" => "grid"
                , "grid-template-columns" => "repeat(" ++ toString (List.length fields) ++ ", auto)"
                , "grid-column-gap" => "1rem"
                ]
            ]
            fields
        ]
    else
        fields


addHeader : Maybe String -> List (Html Msg) -> List (Html Msg)
addHeader header fields =
    case header of
        Nothing ->
            fields

        Just h ->
            Html.legend [] [ Html.text h ] :: fields


addSegment : List (Html Msg) -> Html Msg
addSegment fields =
    Html.fieldset [] fields


renderField : FormErrors -> Field -> Html Msg
renderField errorDict field =
    let
        errors =
            Dict.get field.meta.name errorDict
                |> Maybe.withDefault []

        className =
            case field.meta.required of
                False ->
                    "input-field"

                True ->
                    "required input-field"
    in
    div [ A.class (errorFieldClass className errors) ]
        (List.append
            field.view
            (List.map fieldMessage errors)
        )


dateTimeField : (DateTimePicker.State -> Maybe Date.Date -> Msg) -> FieldMeta -> DateTimePicker.State -> Maybe Date.Date -> List (Html Msg)
dateTimeField msg meta datePickerState date =
    let
        config =
            DateTimePicker.Config.defaultDateTimePickerConfig msg

        i18nConfig =
            DateTimePicker.Config.defaultDateTimeI18n
    in
    [ label [ A.for meta.id ] [ text meta.label ]
    , DateTimePicker.dateTimePickerWithConfig
        { config
            | timePickerType = DateTimePicker.Config.Digital
            , autoClose = True
            , i18n =
                { i18nConfig
                    | inputFormat =
                        { inputFormatter = Date.Format.format "%Y-%m-%d %H:%M"
                        , inputParser = Date.fromString >> Result.toMaybe
                        }
                }
        }
        [ A.class meta.name
        , A.id meta.id
        , A.name meta.name
        , A.type_ "text"
        ]
        datePickerState
        date
    , helpLabel meta
    ]


dateField : (DateTimePicker.State -> Maybe Date.Date -> Msg) -> FieldMeta -> DateTimePicker.State -> Maybe Date.Date -> List (Html Msg)
dateField msg meta datePickerState date =
    let
        config =
            DateTimePicker.Config.defaultDatePickerConfig msg

        i18nConfig =
            DateTimePicker.Config.defaultDateI18n
    in
    [ label [ A.for meta.id ] [ text meta.label ]
    , DateTimePicker.datePickerWithConfig
        { config
            | autoClose = True
            , i18n =
                { i18nConfig
                    | inputFormat =
                        { inputFormatter = Date.Format.format "%Y-%m-%d"
                        , inputParser = Date.fromString >> Result.toMaybe
                        }
                }
        }
        [ A.class meta.name
        , A.id meta.id
        , A.name meta.name
        , A.type_ "text"
        ]
        datePickerState
        date
    , helpLabel meta
    ]


simpleTextField : FieldMeta -> Maybe String -> (String -> Msg) -> List (Html Msg)
simpleTextField meta defaultValue inputMsg =
    [ label [ A.for meta.id ] [ text meta.label ]
    , input
        [ A.id meta.id
        , A.name meta.name
        , A.type_ "text"
        , E.onInput inputMsg
        , A.defaultValue <| Maybe.withDefault "" defaultValue
        ]
        []
    , helpLabel meta
    ]


longTextField : Int -> FieldMeta -> Maybe String -> (String -> Msg) -> List (Html Msg)
longTextField rows meta defaultValue inputMsg =
    [ label [ A.for meta.id ] [ text meta.label ]
    , textarea
        [ A.id meta.id
        , A.name meta.name
        , E.onInput inputMsg
        , A.rows rows
        , A.defaultValue <| Maybe.withDefault "" defaultValue
        ]
        []
    , helpLabel meta
    ]


simpleIntField : FieldMeta -> Maybe Int -> (String -> Msg) -> List (Html Msg)
simpleIntField meta defaultValue inputMsg =
    [ label [ A.for meta.id ] [ text meta.label ]
    , input
        (addDefaultInt defaultValue
            [ A.id meta.id
            , A.name meta.name
            , E.onInput inputMsg
            , A.type_ "number"
            , A.min "0"
            ]
        )
        []
    , helpLabel meta
    ]


addDefaultInt : Maybe Int -> List (Html.Attribute Msg) -> List (Html.Attribute Msg)
addDefaultInt defaultValue attrs =
    case defaultValue of
        Nothing ->
            attrs

        Just num ->
            (A.defaultValue <| toString num) :: attrs


simpleFloatField : FieldMeta -> Maybe Float -> (String -> Msg) -> List (Html Msg)
simpleFloatField meta defaultValue inputMsg =
    [ label [ A.for meta.id ] [ text meta.label ]
    , input
        (addDefaultFloat defaultValue
            [ A.id meta.id
            , A.name meta.name
            , E.onInput inputMsg
            , A.type_ "number"
            , A.step "0.01"
            , A.min "0"
            ]
        )
        []
    , helpLabel meta
    ]


addDefaultFloat : Maybe Float -> List (Html.Attribute Msg) -> List (Html.Attribute Msg)
addDefaultFloat defaultValue attrs =
    case defaultValue of
        Nothing ->
            attrs

        Just num ->
            (A.defaultValue <| toString num) :: attrs


checkboxField : FieldMeta -> Maybe a -> (a -> Bool) -> (Maybe a -> Msg) -> List (Html Msg)
checkboxField meta maybeRec getter toggleMsg =
    let
        checked =
            Maybe.map getter maybeRec |> Maybe.withDefault False
    in
    [ div
        [ E.onClick <| toggleMsg maybeRec
        ]
        [ input
            [ A.id meta.id
            , A.name meta.name
            , A.type_ "checkbox"
            , A.checked checked
            ]
            []
        , label [] [ text <| " " ++ meta.label ]
        , helpLabel meta
        ]
    ]


helpLabel : FieldMeta -> Html Msg
helpLabel meta =
    case meta.help of
        Nothing ->
            text ""

        Just help ->
            div [ A.class "help" ] [ text help ]


submitButton : Maybe a -> Bool -> Html Msg
submitButton maybeItem showAN =
    let
        txt =
            case maybeItem of
                Nothing ->
                    "Create"

                Just _ ->
                    "Update"

        colour =
            case showAN of
                True ->
                    "button-lg button-secondary"

                False ->
                    "button-lg button-primary"
    in
    button [ A.class <| "button button-block" ++ colour, A.id "formSubmitButton" ] [ text txt ]


type alias MultiSelectField a =
    { items : RL.RemoteList { a | pk : Int }
    , selectedPks : Maybe (List Int)
    , defaultPks : Maybe (List Int)
    , filter : Regex.Regex
    , filterMsg : String -> Msg
    , itemView : Maybe (List Int) -> { a | pk : Int } -> Html Msg
    , selectedView : Maybe (List Int) -> { a | pk : Int } -> Html Msg
    }


multiSelectField : FieldMeta -> MultiSelectField a -> List (Html Msg)
multiSelectField meta props =
    let
        pks =
            case props.selectedPks of
                Nothing ->
                    props.defaultPks

                Just pks_ ->
                    Just pks_
    in
    [ label [ A.for meta.id ] [ text meta.label ]
    , helpLabel meta
    , div [ A.class "segment" ]
        [ loadingMessage props.items
        , div [] <| selectedItemsView pks props.selectedView props.items
        , Html.br [] []
        , filterInput props.filterMsg
        , div
            [ A.class "list"
            , A.style
                [ "min-height" => "25vh"
                , "max-height" => "50vh"
                , "overflow-y" => "auto"
                ]
            ]
            (props.items
                |> RL.toList
                |> List.filter (filterRecord props.filter)
                |> List.map (props.itemView pks)
            )
        ]
    ]


selectedItemsView : Maybe (List Int) -> (Maybe (List Int) -> { a | pk : Int } -> Html Msg) -> RL.RemoteList { a | pk : Int } -> List (Html Msg)
selectedItemsView maybePks render rl =
    case maybePks of
        Nothing ->
            []

        Just pks ->
            rl
                |> RL.toList
                |> List.filter (\x -> List.member x.pk pks)
                |> List.map (render maybePks)


loadingMessage : RL.RemoteList a -> Html Msg
loadingMessage rl =
    case rl of
        RL.FinalPageReceived _ ->
            text ""

        RL.WaitingOnRefresh _ ->
            text ""

        RL.RespFailed _ _ ->
            text "Uh oh, something went wrong there. Maybe try reloading the page?"

        _ ->
            text "Fetching some data..."


selectedIcon : List Int -> { a | pk : Int } -> Html Msg
selectedIcon selectedPks item =
    case List.member item.pk selectedPks of
        False ->
            text ""

        True ->
            i [ A.class "fa fa-check", A.style [ "color" => "var(--state-primary)" ] ] []


fieldMessage : String -> Html Msg
fieldMessage message =
    div [ A.class "alert alert-danger" ] [ text message ]


errorFieldClass : String -> List String -> String
errorFieldClass base errors =
    case List.isEmpty errors of
        True ->
            base

        False ->
            "input-invalid " ++ base


formClass : FormStatus -> String
formClass status =
    case status of
        InProgress ->
            "loading"

        _ ->
            ""



-- Sending SMS Forms


contentField : FieldMeta -> Int -> (String -> Msg) -> String -> List (Html Msg)
contentField meta smsCharLimit msg content =
    [ label [ A.for meta.id ] [ text meta.label ]
    , textarea
        [ A.id meta.id
        , A.name meta.name
        , A.rows (smsCharLimit |> toFloat |> (/) 160 |> ceiling)
        , A.cols 40
        , onInput msg
        , A.value content
        ]
        []
    ]


timeField : (DateTimePicker.State -> Maybe Date.Date -> Msg) -> FieldMeta -> DateTimePicker.State -> Maybe Date.Date -> List (Html Msg)
timeField msg meta datePickerState date =
    dateTimeField msg meta datePickerState date



-- Send Button


isDisabled : Maybe Float -> Html.Attribute msg
isDisabled cost =
    case cost of
        Nothing ->
            A.disabled True

        Just _ ->
            A.disabled False


sendButtonText : Maybe Float -> String
sendButtonText cost =
    case cost of
        Nothing ->
            "0.00"

        Just c ->
            Round.round 2 c


sendButton : Maybe Float -> Html Msg
sendButton cost =
    button
        [ isDisabled cost, A.id "send_button", A.class "button" ]
        [ text ("Send ($" ++ sendButtonText cost ++ ")") ]
