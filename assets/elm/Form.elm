module Form exposing
    ( Field
    , FieldGroupConfig
    , FieldMeta
    , FormErrors
    , FormItem(..)
    , FormStatus(..)
    , MultiSelectField
    , MultiSelectItemProps
    , UpdateResp
    , addDefaultFloat
    , addDefaultInt
    , addGroupHelpText
    , addHeader
    , addPk
    , addSegment
    , addSideBySide
    , checkboxField
    , contentField
    , dateField
    , dateTimeField
    , decodeFormResp
    , defaultFieldGroupConfig
    , errFormRespUpdate
    , extractBool
    , extractField
    , extractFloat
    , fieldGroupHelp
    , fieldMessage
    , form
    , formDecodeError
    , formErrors
    , helpLabel
    , isDisabled
    , label
    , loadingMessage
    , longTextField
    , multiSelectField
    , multiSelectItemHelper
    , multiSelectItemLabelHelper
    , noErrors
    , okFormRespUpdate
    , renderField
    , renderFormError
    , renderItem
    , requiredClass
    , selectedIcon
    , selectedItemsView
    , sendButton
    , sendButtonText
    , setInProgress
    , simpleFloatField
    , simpleIntField
    , simpleTextField
    , submitButton
    , timeField
    )

import Css
import Date
import DateFormat
import DateTimePicker
import DateTimePicker.Config
import Dict
import FilteringTable exposing (filterInput, filterRecord)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Notification as Notif exposing (DjangoMessage, decodeDjangoMessage)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Round



-- Model


type FormStatus
    = NoAction
    | InProgress
    | Success
    | Failed FormErrors


type alias FormResp =
    { messages : List DjangoMessage
    , errors : FormErrors
    }


decodeFormResp : Decode.Decoder FormResp
decodeFormResp =
    decode FormResp
        |> required "messages" (Decode.list decodeDjangoMessage)
        |> required "errors" (Decode.dict (Decode.list Decode.string))


type alias FormErrors =
    Dict.Dict String (List String)


noErrors : FormErrors
noErrors =
    Dict.empty


formDecodeError : String -> FormErrors
formDecodeError err =
    Dict.insert "__all__" [ "Something strange happend there. (" ++ err ++ ")" ] noErrors


formErrors : FormStatus -> FormErrors
formErrors formStatus =
    case formStatus of
        Failed errors ->
            errors

        _ ->
            noErrors


type FormItem msg
    = FormField (Field msg)
    | FieldGroup (FieldGroupConfig msg) (List (Field msg))


type alias FieldGroupConfig msg =
    { header : Maybe String
    , helpText : Maybe (Html msg)
    , sideBySide : Maybe Int
    }


defaultFieldGroupConfig : FieldGroupConfig msg
defaultFieldGroupConfig =
    FieldGroupConfig Nothing Nothing Nothing


type alias Field msg =
    { meta : FieldMeta
    , view : FieldMeta -> List (Html msg)
    }


type alias FieldMeta =
    { required : Bool
    , id : String
    , name : String
    , label : String
    , help : Maybe String
    }


type alias Resp =
    { body : String
    , code : Int
    }



-- Helpers


setInProgress : { model | formStatus : FormStatus } -> { model | formStatus : FormStatus }
setInProgress model =
    { model | formStatus = InProgress }


handleGoodFormResp : Resp -> ( FormStatus, Notif.Notifications )
handleGoodFormResp resp =
    case Decode.decodeString decodeFormResp resp.body of
        Ok data ->
            ( Success
            , Notif.createListOfDjangoMessages data.messages
            )

        Err err ->
            ( Failed <| formDecodeError err, [] )


handleBadFormResp : Http.Error -> ( FormStatus, Notif.Notifications )
handleBadFormResp err =
    case err of
        Http.BadStatus resp ->
            case Decode.decodeString decodeFormResp resp.body of
                Ok data ->
                    ( Failed data.errors
                    , Notif.createListOfDjangoMessages data.messages
                    )

                Err e ->
                    ( Failed <| formDecodeError e
                    , [ Notif.refreshNotifMessage ]
                    )

        _ ->
            ( Failed noErrors
            , [ Notif.refreshNotifMessage ]
            )


type alias UpdateResp msg model =
    { pageModel : model
    , cmd : Cmd msg
    , notifications : Notif.Notifications
    , maybeNewUrl : Maybe String
    }


okFormRespUpdate : { props | successPageUrl : String } -> Resp -> { model | formStatus : FormStatus } -> UpdateResp msg { model | formStatus : FormStatus }
okFormRespUpdate props resp model =
    let
        ( formStatus, newNotifs ) =
            handleGoodFormResp resp
    in
    UpdateResp
        { model | formStatus = formStatus }
        Cmd.none
        newNotifs
        (Just props.successPageUrl)


errFormRespUpdate : Http.Error -> { model | formStatus : FormStatus } -> UpdateResp msg { model | formStatus : FormStatus }
errFormRespUpdate err model =
    let
        ( formStatus, newNotifs ) =
            handleBadFormResp err
    in
    UpdateResp
        { model | formStatus = formStatus }
        Cmd.none
        newNotifs
        Nothing


addPk : Maybe { a | pk : Int } -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addPk maybeRecord body =
    case maybeRecord of
        Nothing ->
            body

        Just rec ->
            ( "pk", Encode.int rec.pk ) :: body


extractBool : (a -> Bool) -> Maybe Bool -> Maybe a -> Bool
extractBool fn field maybeRec =
    case field of
        Nothing ->
            Maybe.map fn maybeRec
                |> Maybe.withDefault False

        Just b ->
            b


extractField : (a -> String) -> Maybe String -> Maybe a -> String
extractField fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to ""
            Maybe.map fn maybeRec
                |> Maybe.withDefault ""

        Just s ->
            s


extractFloat : (a -> Float) -> Maybe Float -> Maybe a -> Float
extractFloat fn field maybeRec =
    case field of
        Nothing ->
            -- never edited the field, use existing or default to 0
            Maybe.map fn maybeRec
                |> Maybe.withDefault 0

        Just s ->
            s



-- View


form : FormStatus -> List (FormItem msg) -> msg -> Html msg -> Html msg
form formStatus items submitMsg button_ =
    case formStatus of
        InProgress ->
            loader

        _ ->
            Html.form [ E.onSubmit submitMsg, Css.max_w_md, Css.mx_auto ] <|
                renderFormError formStatus
                    ++ List.map (renderItem <| formErrors formStatus) items
                    ++ [ button_ ]


renderFormError : FormStatus -> List (Html msg)
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


renderItem : FormErrors -> FormItem msg -> Html msg
renderItem errorDict item =
    case item of
        FormField field ->
            renderField errorDict field

        FieldGroup config fields ->
            fieldGroupHelp config <|
                List.map (renderField errorDict) fields


fieldGroupHelp : FieldGroupConfig msg -> List (Html msg) -> Html msg
fieldGroupHelp config fields =
    fields
        |> addSideBySide config.sideBySide
        |> addGroupHelpText config.helpText
        |> addHeader config.header
        |> addSegment


addSideBySide : Maybe Int -> List (Html msg) -> List (Html msg)
addSideBySide config fields =
    case config of
        Just num ->
            let
                maxWidth =
                    A.style [ ( "max-width", (toString <| 100 // num) ++ "%" ) ]

                minWidth =
                    A.style [ ( "min-width", (toString <| 100 // num) ++ "%" ) ]
            in
            [ Html.div
                [ Css.flex
                , Css.flex_wrap
                ]
                (List.map (Html.div [ Css.flex_1, minWidth, maxWidth ] << List.singleton) fields)
            ]

        Nothing ->
            fields


addGroupHelpText : Maybe (Html msg) -> List (Html msg) -> List (Html msg)
addGroupHelpText maybeSnippet fields =
    case maybeSnippet of
        Just snippet ->
            snippet :: fields

        Nothing ->
            fields


addHeader : Maybe String -> List (Html msg) -> List (Html msg)
addHeader header fields =
    case header of
        Nothing ->
            fields

        Just h ->
            Html.h4 [] [ Html.text h ] :: fields


addSegment : List (Html msg) -> Html msg
addSegment fields =
    Html.div [ Css.mt_4 ] fields


requiredClass : FieldMeta -> Html.Attribute msg
requiredClass { required } =
    if required then
        A.class "required"

    else
        A.class ""


label : FieldMeta -> Html msg
label meta =
    Html.label [ A.for meta.id, Css.label, requiredClass meta ] [ Html.text meta.label ]


renderField : FormErrors -> Field msg -> Html msg
renderField errorDict field =
    let
        errors =
            Dict.get field.meta.name errorDict
                |> Maybe.withDefault []
    in
    Html.div [ Css.px_1, A.required field.meta.required ]
        (List.append
            (field.view field.meta)
            (List.map fieldMessage errors)
        )


dateTimeField : (DateTimePicker.State -> Maybe Date.Date -> msg) -> DateTimePicker.State -> Maybe Date.Date -> FieldMeta -> List (Html msg)
dateTimeField msg datePickerState date meta =
    let
        config =
            DateTimePicker.Config.defaultDateTimePickerConfig msg

        i18nConfig =
            DateTimePicker.Config.defaultDateTimeI18n
    in
    [ label meta
    , DateTimePicker.dateTimePickerWithConfig
        { config
            | timePickerType = DateTimePicker.Config.Digital
            , autoClose = False
            , i18n =
                { i18nConfig
                    | inputFormat =
                        { inputFormatter =
                            DateFormat.format
                                [ DateFormat.yearNumber
                                , DateFormat.text "-"
                                , DateFormat.monthFixed
                                , DateFormat.text "-"
                                , DateFormat.dayOfMonthFixed
                                , DateFormat.text " "
                                , DateFormat.hourMilitaryFixed
                                , DateFormat.text ":"
                                , DateFormat.minuteFixed
                                ]
                        , inputParser = Date.fromString >> Result.toMaybe
                        }
                }
        }
        [ A.class meta.name
        , A.id meta.id
        , A.name meta.name
        , A.type_ "text"
        , Css.formInput
        ]
        datePickerState
        date
    , helpLabel meta
    ]


dateField : (DateTimePicker.State -> Maybe Date.Date -> msg) -> DateTimePicker.State -> Maybe Date.Date -> FieldMeta -> List (Html msg)
dateField msg datePickerState date meta =
    let
        config =
            DateTimePicker.Config.defaultDatePickerConfig msg

        i18nConfig =
            DateTimePicker.Config.defaultDateI18n
    in
    [ label meta
    , DateTimePicker.datePickerWithConfig
        { config
            | autoClose = True
            , i18n =
                { i18nConfig
                    | inputFormat =
                        { inputFormatter =
                            DateFormat.format
                                [ DateFormat.yearNumber
                                , DateFormat.text "-"
                                , DateFormat.monthFixed
                                , DateFormat.text "-"
                                , DateFormat.dayOfMonthFixed
                                ]
                        , inputParser = Date.fromString >> Result.toMaybe
                        }
                }
        }
        [ A.class meta.name
        , A.id meta.id
        , A.name meta.name
        , A.type_ "text"
        , Css.formInput
        ]
        datePickerState
        date
    , helpLabel meta
    ]


simpleTextField : Maybe String -> (String -> msg) -> FieldMeta -> List (Html msg)
simpleTextField defaultValue inputMsg meta =
    [ label meta
    , Html.input
        [ A.id meta.id
        , A.name meta.name
        , A.type_ "text"
        , E.onInput inputMsg
        , A.defaultValue <| Maybe.withDefault "" defaultValue
        , Css.formInput
        ]
        []
    , helpLabel meta
    ]


longTextField : Int -> Maybe String -> (String -> msg) -> FieldMeta -> List (Html msg)
longTextField rows defaultValue inputMsg meta =
    [ label meta
    , Html.textarea
        [ A.id meta.id
        , A.name meta.name
        , E.onInput inputMsg
        , A.rows rows
        , A.defaultValue <| Maybe.withDefault "" defaultValue
        , Css.formInput
        ]
        []
    , helpLabel meta
    ]


simpleIntField : Maybe Int -> (String -> msg) -> FieldMeta -> List (Html msg)
simpleIntField defaultValue inputMsg meta =
    [ label meta
    , Html.input
        (addDefaultInt defaultValue
            [ A.id meta.id
            , A.name meta.name
            , E.onInput inputMsg
            , A.type_ "number"
            , A.min "0"
            , Css.formInput
            ]
        )
        []
    , helpLabel meta
    ]


addDefaultInt : Maybe Int -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addDefaultInt defaultValue attrs =
    case defaultValue of
        Nothing ->
            attrs

        Just num ->
            (A.defaultValue <| toString num) :: attrs


simpleFloatField : Maybe Float -> (String -> msg) -> FieldMeta -> List (Html msg)
simpleFloatField defaultValue inputMsg meta =
    [ label meta
    , Html.input
        (addDefaultFloat defaultValue
            [ A.id meta.id
            , A.name meta.name
            , E.onInput inputMsg
            , A.type_ "number"
            , A.step "0.0001"
            , A.min "0"
            , Css.formInput
            ]
        )
        []
    , helpLabel meta
    ]


addDefaultFloat : Maybe Float -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addDefaultFloat defaultValue attrs =
    case defaultValue of
        Nothing ->
            attrs

        Just num ->
            (A.defaultValue <| toString num) :: attrs


checkboxField : Maybe a -> (a -> Bool) -> (Maybe a -> msg) -> FieldMeta -> List (Html msg)
checkboxField maybeRec getter toggleMsg meta =
    let
        checked =
            Maybe.map getter maybeRec |> Maybe.withDefault False
    in
    [ Html.div [ Css.flex ]
        [ Html.input
            [ A.id meta.id
            , A.name meta.name
            , A.type_ "checkbox"
            , A.checked checked
            , E.onClick <| toggleMsg maybeRec
            , Css.label
            ]
            []
        , Html.label [ Css.label, Css.mx_1 ] [ Html.text <| " " ++ meta.label ]
        ]
    , Html.div [ A.style [ ( "margin-top", "-.25rem" ) ] ] [ helpLabel meta ]
    ]


helpLabel : { a | help : Maybe String } -> Html msg
helpLabel { help } =
    case help of
        Nothing ->
            Html.text ""

        Just h ->
            Html.p
                [ Css.text_grey_darker
                , Css.text_xs
                , Css.font_light
                , Css.pb_2
                , Css.pt_1
                , Css.pl_2
                ]
                [ Html.text h ]


submitButton : Maybe a -> Html msg
submitButton maybeItem =
    let
        txt =
            case maybeItem of
                Nothing ->
                    "Create"

                Just _ ->
                    "Update"
    in
    Html.button
        [ A.id "formSubmitButton"
        , Css.btn
        , Css.btn_purple
        , Css.mt_4
        ]
        [ Html.text txt ]


type alias MultiSelectField msg a =
    { items : RL.RemoteList { a | pk : Int }
    , selectedPks : Maybe (List Int)
    , defaultPks : Maybe (List Int)
    , filter : Regex.Regex
    , filterMsg : String -> msg
    , itemView : Maybe (List Int) -> { a | pk : Int } -> Html msg
    , selectedView : Maybe (List Int) -> { a | pk : Int } -> Html msg
    }


multiSelectField : MultiSelectField msg a -> FieldMeta -> List (Html msg)
multiSelectField props meta =
    let
        pks =
            case props.selectedPks of
                Nothing ->
                    props.defaultPks

                Just pks_ ->
                    Just pks_
    in
    [ label meta
    , helpLabel meta
    , loadingMessage props.items
    , Html.div [ Css.flex, Css.mb_2 ] <| selectedItemsView pks props.selectedView props.items
    , filterInput props.filterMsg
    , Html.div [ Css.max_w_md, Css.twoColGrid ]
        (props.items
            |> RL.toList
            |> List.filter (filterRecord props.filter)
            |> List.map (props.itemView pks)
        )
    ]


type alias MultiSelectItemProps msg a =
    { itemToStr : { a | pk : Int } -> String
    , maybeSelectedPks : Maybe (List Int)
    , itemToKey : { a | pk : Int } -> String
    , toggleMsg : Int -> msg
    , itemToId : { a | pk : Int } -> String
    }


multiSelectItemHelper : MultiSelectItemProps msg { a | pk : Int } -> { a | pk : Int } -> Html msg
multiSelectItemHelper props item =
    let
        selectedPks =
            case props.maybeSelectedPks of
                Nothing ->
                    []

                Just pks ->
                    pks
    in
    Html.Keyed.node "div"
        [ E.onClick <| props.toggleMsg item.pk
        , A.id <| props.itemToId item
        , Css.border_b_2
        , Css.cursor_pointer
        ]
        [ ( props.itemToKey item
          , Html.div []
                [ selectedIcon selectedPks item
                , Html.text <| props.itemToStr item
                ]
          )
        ]


multiSelectItemLabelHelper : ({ a | pk : Int } -> String) -> msg -> { a | pk : Int } -> Html msg
multiSelectItemLabelHelper itemToStr toggleMsg item =
    Html.div
        [ E.onClick toggleMsg
        , Css.pill_sm
        , Css.pill_purple
        , Css.mr_1
        , Css.cursor_pointer
        , Css.p_1
        ]
        [ Html.text <| itemToStr item ]


selectedItemsView : Maybe (List Int) -> (Maybe (List Int) -> { a | pk : Int } -> Html msg) -> RL.RemoteList { a | pk : Int } -> List (Html msg)
selectedItemsView maybePks render rl =
    case maybePks of
        Nothing ->
            []

        Just pks ->
            rl
                |> RL.toList
                |> List.filter (\x -> List.member x.pk pks)
                |> List.map (render maybePks)


loadingMessage : RL.RemoteList a -> Html msg
loadingMessage rl =
    case rl of
        RL.FinalPageReceived _ ->
            Html.text ""

        RL.WaitingOnRefresh _ ->
            Html.text ""

        RL.RespFailed _ _ ->
            Html.text "Uh oh, something went wrong there. Maybe try reloading the page?"

        _ ->
            Html.text "Fetching some data..."


selectedIcon : List Int -> { a | pk : Int } -> Html msg
selectedIcon selectedPks item =
    case List.member item.pk selectedPks of
        False ->
            Html.text ""

        True ->
            Html.i [ A.class "fa fa-check" ] []


fieldMessage : String -> Html msg
fieldMessage message =
    Html.div [ Css.fieldError ] [ Html.text message ]



-- Sending SMS Forms


contentField : Int -> (String -> msg) -> String -> FieldMeta -> List (Html msg)
contentField smsCharLimit msg content meta =
    [ label meta
    , Html.textarea
        [ A.id meta.id
        , A.name meta.name
        , A.rows (smsCharLimit |> toFloat |> (/) 160 |> ceiling)
        , A.cols 40
        , E.onInput msg
        , A.value content
        , Css.formInput
        ]
        []
    ]


timeField : (DateTimePicker.State -> Maybe Date.Date -> msg) -> DateTimePicker.State -> Maybe Date.Date -> FieldMeta -> List (Html msg)
timeField msg datePickerState date meta =
    dateTimeField msg datePickerState date meta



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


sendButton : Maybe Float -> Html msg
sendButton cost =
    Html.button
        [ isDisabled cost, A.id "send_button", Css.btn_purple, Css.btn ]
        [ Html.text ("Send ($" ++ sendButtonText cost ++ ")") ]
