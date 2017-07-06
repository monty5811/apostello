module Forms.View exposing (..)

import Date
import Date.Format
import DateTimePicker
import DateTimePicker.Config
import Dict
import FilteringTable exposing (filterRecord)
import Forms.Model exposing (..)
import Html exposing (Html, button, div, i, input, label, text, textarea)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg)
import Regex
import RemoteList as RL


form : FormStatus -> List FormItem -> Msg -> Html Msg -> Html Msg
form formStatus items submitMsg button_ =
    Html.form
        [ A.class <| formClass formStatus
        , E.onSubmit submitMsg
        ]
    <|
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
            Html.h4 [ A.class "ui dividing header" ] [ Html.text header ]

        FieldGroup config fields ->
            fieldGroupHelp config <|
                List.map (renderField errorDict) fields


fieldGroupHelp : FieldGroupConfig -> List (Html Msg) -> Html Msg
fieldGroupHelp config fields =
    fields
        |> addSideBySide config.sideBySide
        |> addHeader config.header
        |> addSegment config.useSegment


addSideBySide : Bool -> List (Html Msg) -> Html Msg
addSideBySide add fields =
    if add then
        Html.div [ A.class "equal width fields" ] fields
    else
        Html.div [] fields


addHeader : Maybe String -> Html Msg -> Html Msg
addHeader header fields =
    case header of
        Nothing ->
            fields

        Just h ->
            Html.div [] [ Html.h4 [] [ Html.text h ], fields ]


addSegment : Bool -> Html Msg -> Html Msg
addSegment seg fields =
    if seg then
        Html.div [ A.class "ui raised segment" ] [ fields ]
    else
        fields


renderField : FormErrors -> Field -> Html Msg
renderField errorDict field =
    let
        errors =
            Dict.get field.meta.name errorDict
                |> Maybe.withDefault []

        className =
            case field.meta.required of
                False ->
                    "field"

                True ->
                    "required field"
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

        divClass =
            case checked of
                True ->
                    "ui checked checkbox"

                False ->
                    "ui checkbox"
    in
    [ div
        [ A.class divClass
        , E.onClick <| toggleMsg maybeRec
        ]
        [ input
            [ A.id meta.id
            , A.name meta.name
            , A.type_ "checkbox"
            , A.checked checked
            ]
            []
        , label [] [ text meta.label ]
        , helpLabel meta
        ]
    ]


helpLabel : FieldMeta -> Html Msg
helpLabel meta =
    case meta.help of
        Nothing ->
            text ""

        Just help ->
            div [ A.class "ui label" ] [ text help ]


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
                    "disabled"

                False ->
                    "primary"
    in
    button [ A.class <| "ui " ++ colour ++ " button" ] [ text txt ]


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
    , div [ A.class "ui raised segment" ]
        [ loadingMessage props.items
        , selectedItemsView pks props.selectedView props.items
        , div [ A.class "ui left icon large transparent fluid input" ]
            [ input
                [ A.placeholder "Filter..."
                , A.type_ "text"
                , E.onInput props.filterMsg
                ]
                []
            , i [ A.class "violet filter icon" ] []
            ]
        , div
            [ A.class "ui divided selection list"
            , A.style
                [ ( "min-height", "25vh" )
                , ( "max-height", "50vh" )
                , ( "overflow-y", "auto" )
                ]
            ]
            (props.items
                |> RL.toList
                |> List.filter (filterRecord props.filter)
                |> List.map (props.itemView pks)
            )
        ]
    ]


selectedItemsView : Maybe (List Int) -> (Maybe (List Int) -> { a | pk : Int } -> Html Msg) -> RL.RemoteList { a | pk : Int } -> Html Msg
selectedItemsView maybePks render rl =
    case maybePks of
        Nothing ->
            div [] []

        Just pks ->
            rl
                |> RL.toList
                |> List.filter (\x -> List.member x.pk pks)
                |> List.map (render maybePks)
                |> div []


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
            i [ A.class "check icon", A.style [ ( "color", "#603cba" ) ] ] []


fieldMessage : String -> Html Msg
fieldMessage message =
    div [ A.class "ui error message" ] [ text message ]


errorFieldClass : String -> List String -> String
errorFieldClass base errors =
    case List.isEmpty errors of
        True ->
            base

        False ->
            "error " ++ base


formClass : FormStatus -> String
formClass status =
    case status of
        NoAction ->
            "ui form"

        InProgress ->
            "ui loading form"

        Success ->
            "ui success form"

        Failed _ ->
            "ui error form"
