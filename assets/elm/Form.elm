module Form exposing
    ( Field
    , FieldGroupConfig
    , FieldMeta
    , Form
    , FormErrors
    , FormItem(..)
    , Item
    , MultiSelectField
    , MultiSelectItemProps
    , UpdateResp
    , addPk
    , checkboxField
    , contentField
    , dateField
    , dateTimeField
    , defaultFieldGroupConfig
    , errFormRespUpdate
    , form
    , formLoading
    , getCurrent
    , getDirty
    , getOriginal
    , helpLabel
    , itemGetCurrent
    , itemGetOriginal
    , label
    , loadingMessage
    , longTextField
    , multiSelectField
    , multiSelectItemHelper
    , multiSelectItemLabelHelper
    , okFormRespUpdate
    , selectedIcon
    , sendButton
    , setInProgress
    , showArchiveNotice
    , simpleFloatField
    , simpleIntField
    , simpleTextField
    , startCreating
    , startUpdating
    , submitButton
    , to404
    , toError
    , updateField
    )

import Css
import Date
import DateFormat
import DateTimePicker
import DateTimePicker.Config
import Dict
import FilteringTable exposing (filterInput, filterRecord)
import Future.String
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Notification as Notif exposing (DjangoMessage, decodeDjangoMessage)
import Pages.Error404 as Error404
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Round



-- Model


type Form item tmpState
    = Loading
    | Item404
    | Error String
    | Editing (Item item) tmpState FormErrors
    | Saving (Item item) tmpState


type Item item
    = Creating item
    | Updating item item


itemGetCurrent : Item item -> item
itemGetCurrent item =
    case item of
        Creating current ->
            current

        Updating _ current ->
            current


itemGetOriginal : Item item -> Maybe item
itemGetOriginal item =
    case item of
        Creating current ->
            Nothing

        Updating original _ ->
            Just original


formLoading : Form item tmpState
formLoading =
    Loading


startUpdating : item -> tmpState -> Form item tmpState
startUpdating original tmpState =
    Editing (Updating original original) tmpState noErrors


startCreating : item -> tmpState -> Form item tmpState
startCreating default tmpState =
    Editing (Creating default) tmpState noErrors


to404 : Form item tmpState
to404 =
    Item404


toError : String -> Form item tmpState
toError err =
    Error err


toSaving : Form item tmpState -> Form item tmpState
toSaving form =
    case form of
        Loading ->
            Loading

        Item404 ->
            Item404

        Error err ->
            Error err

        Editing itemState tmpState errs ->
            Saving itemState tmpState

        Saving itemState tmpState ->
            Saving itemState tmpState


updateField : (item -> tmpState -> ( item, tmpState )) -> Form item tmpState -> Form item tmpState
updateField fn form =
    case form of
        Loading ->
            form

        Item404 ->
            form

        Error _ ->
            form

        Editing itemState tmpState errs ->
            case itemState of
                Creating item ->
                    let
                        ( newItem, newTmpState ) =
                            fn item tmpState
                    in
                    Editing (Creating newItem) newTmpState errs

                Updating original item ->
                    let
                        ( newItem, newTmpState ) =
                            fn item tmpState
                    in
                    Editing (Updating original newItem) newTmpState errs

        Saving itemState tmpState ->
            Saving itemState tmpState


updateItem : (item -> item) -> Form item tmpState -> Form item tmpState
updateItem fn form =
    case form of
        Loading ->
            Loading

        Item404 ->
            Item404

        Error err ->
            Error err

        Editing itemState tmpState errs ->
            Editing (updateItemHelp fn itemState) tmpState errs

        Saving itemState tmpState ->
            Saving (updateItemHelp fn itemState) tmpState


updateItemHelp : (item -> item) -> Item item -> Item item
updateItemHelp fn itemState =
    case itemState of
        Creating current ->
            Creating <| fn current

        Updating original current ->
            Updating original <| fn current


getCurrent : Form item tmpState -> Maybe item
getCurrent form =
    case form of
        Editing itemState _ _ ->
            Just <| itemGetCurrent itemState
        Saving itemState  _ ->
            Just <| itemGetCurrent itemState

        _ ->
            Nothing


getOriginal : Form item tmpState -> Maybe item
getOriginal form =
    case form of
        Editing itemState _ _ ->
            itemGetOriginal itemState

        _ ->
            Nothing


getDirty : Form item tmpState -> Maybe tmpState
getDirty form =
    case form of
        Editing _ tmpState _ ->
            Just tmpState

        _ ->
            Nothing


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


formErrors : Form item tmpState -> FormErrors
formErrors form =
    case form of
        Editing _ _ errors ->
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


setInProgress : { model | form : Form item tmpState } -> { model | form : Form item tmpState }
setInProgress model =
    { model | form = toSaving model.form }


handleGoodFormResp : Form item tmpState -> Resp -> ( Form item tmpState, Notif.Notifications )
handleGoodFormResp form resp =
    case form of
        Saving item tmpState ->
            case Decode.decodeString decodeFormResp resp.body of
                Ok data ->
                    ( Editing item tmpState noErrors
                    , Notif.createListOfDjangoMessages data.messages
                    )

                Err err ->
                    ( Editing item tmpState <| formDecodeError err, [] )

        _ ->
            ( form, [] )


handleBadFormResp : Form item tmpState -> Http.Error -> ( Form item tmpState, Notif.Notifications )
handleBadFormResp form err =
    case form of
        Saving item tmpState ->
            case err of
                Http.BadStatus resp ->
                    case Decode.decodeString decodeFormResp resp.body of
                        Ok data ->
                            ( Editing item tmpState data.errors
                            , Notif.createListOfDjangoMessages data.messages
                            )

                        Err e ->
                            ( Editing item tmpState <| formDecodeError e
                            , [ Notif.refreshNotifMessage ]
                            )

                _ ->
                    ( Saving item tmpState
                    , [ Notif.refreshNotifMessage ]
                    )

        _ ->
            ( form, [] )


type alias UpdateResp msg model =
    { pageModel : model
    , cmd : Cmd msg
    , notifications : Notif.Notifications
    , maybeNewUrl : Maybe String
    }


okFormRespUpdate : { props | successPageUrl : String } -> Resp -> { model | form : Form item tmpState } -> UpdateResp msg { model | form : Form item tmpState }
okFormRespUpdate props resp model =
    let
        ( form, newNotifs ) =
            handleGoodFormResp model.form resp
    in
    UpdateResp
        { model | form = form }
        Cmd.none
        newNotifs
        (Just props.successPageUrl)


errFormRespUpdate : Http.Error -> { model | form : Form item tmpState } -> UpdateResp msg { model | form : Form item tmpState }
errFormRespUpdate err model =
    let
        ( form, newNotifs ) =
            handleBadFormResp model.form err
    in
    UpdateResp
        { model | form = form }
        Cmd.none
        newNotifs
        Nothing


addPk : Maybe Int -> List ( String, Encode.Value ) -> List ( String, Encode.Value )
addPk maybePk body =
    case maybePk of
        Nothing ->
            body

        Just pk ->
            ( "pk", Encode.int pk ) :: body



-- View


form : Form item tmpState -> (Item item -> tmpState -> List (FormItem msg)) -> msg -> (Item item -> Html msg) -> Html msg
form form items submitMsg button_ =
    case form of
        Loading ->
            loader

        Item404 ->
            Error404.view

        Error err ->
            Html.div [ Css.alert, Css.alert_danger ]
                [ Html.p [] [ Html.text "Uh, oh. Something went wrong there. Try refreshing the page. More details:" ]
                , Html.pre [] [ Html.text err ]
                ]

        Editing itemState tmpState errors ->
            Html.form [ E.onSubmit submitMsg, Css.max_w_md, Css.mx_auto ] <|
                renderFormError form
                    ++ List.map (renderItem <| formErrors form) (items itemState tmpState)
                    ++ [ button_ itemState ]

        Saving _ _ ->
            loader


renderFormError : Form item tmpState -> List (Html msg)
renderFormError form =
    case form of
        Editing _ _ errors ->
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
                    A.style [ ( "max-width", (Future.String.fromInt <| 100 // num) ++ "%" ) ]

                minWidth =
                    A.style [ ( "min-width", (Future.String.fromInt <| 100 // num) ++ "%" ) ]
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


dateTimeField : (DateTimePicker.State -> Maybe Date.Date -> msg) -> DateTimePicker.State -> (a -> Maybe Date.Date) -> Item a -> FieldMeta -> List (Html msg)
dateTimeField msg datePickerState getDate item meta =
    let
        config =
            DateTimePicker.Config.defaultDateTimePickerConfig msg

        i18nConfig =
            DateTimePicker.Config.defaultDateTimeI18n

        date =
            getDate (itemGetCurrent item)
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


dateField : (DateTimePicker.State -> Maybe Date.Date -> msg) -> DateTimePicker.State -> (item -> Maybe Date.Date) -> Item item -> FieldMeta -> List (Html msg)
dateField msg datePickerState getValue item meta =
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
        (getValue <| itemGetCurrent item)
    , helpLabel meta
    ]


simpleTextField : { getValue : item -> String, item : Item item, onInput : String -> msg } -> FieldMeta -> List (Html msg)
simpleTextField { getValue, item, onInput } meta =
    [ label meta
    , Html.input
        ([ A.id meta.id
         , A.name meta.name
         , A.type_ "text"
         , E.onInput onInput
         , A.value (getValue (itemGetCurrent item))
         , Css.formInput
         ]
            |> addDefaultText getValue item
        )
        []
    , helpLabel meta
    ]


addDefaultText : (item -> String) -> Item item -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addDefaultText getValue itemState attrs =
    case itemState of
        Creating _ ->
            attrs

        Updating original _ ->
            A.defaultValue (getValue original) :: attrs


longTextField : Int -> { getValue : item -> String, item : Item item, onInput : String -> msg } -> FieldMeta -> List (Html msg)
longTextField rows { getValue, item, onInput } meta =
    [ label meta
    , Html.textarea
        ([ A.id meta.id
         , A.name meta.name
         , E.onInput onInput
         , A.rows rows
         , A.value (getValue (itemGetCurrent item))
         , Css.formInput
         ]
            |> addDefaultText getValue item
        )
        []
    , helpLabel meta
    ]


{-| Need `Maybe Int` to handle blank field
-}
simpleIntField : { getValue : item -> Maybe Int, item : Item item, tmpState : Maybe String, onInput : String -> msg } -> FieldMeta -> List (Html msg)
simpleIntField { getValue, item, onInput, tmpState } meta =
    [ label meta
    , Html.input
        ([ A.id meta.id
         , A.name meta.name
         , E.onInput onInput
         , A.type_ "number"
         , A.min "0"
         , Css.formInput
         ]
            |> addDefaultInt getValue item
            |> addCurrentInt tmpState getValue item
        )
        []
    , helpLabel meta
    ]


addDefaultInt : (item -> Maybe Int) -> Item item -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addDefaultInt getValue itemState attrs =
    case itemState of
        Creating _ ->
            attrs

        Updating original _ ->
            case getValue original of
                Just num ->
                    (A.defaultValue <| Future.String.fromInt num) :: attrs

                Nothing ->
                    attrs


addCurrentInt : Maybe String -> (item -> Maybe Int) -> Item item -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addCurrentInt raw getValue itemState attrs =
    case raw of
        Just rawVal ->
            A.value rawVal :: attrs

        Nothing ->
            case itemState of
                Creating _ ->
                    attrs

                Updating _ current ->
                    case getValue current of
                        Just num ->
                            (A.value <| Future.String.fromInt num) :: attrs

                        Nothing ->
                            attrs


{-| Need `Maybe Int` to handle blank field
-}
simpleFloatField : { getValue : item -> Maybe Float, item : Item item, tmpState : Maybe String, onInput : String -> msg } -> FieldMeta -> List (Html msg)
simpleFloatField { getValue, item, tmpState, onInput } meta =
    [ label meta
    , Html.input
        ([ A.id meta.id
         , A.name meta.name
         , E.onInput onInput
         , A.type_ "number"
         , A.step "0.0001"
         , A.min "0"
         , Css.formInput
         ]
            |> addDefaultFloat getValue item
            |> addCurrentFloat tmpState getValue item
        )
        []
    , helpLabel meta
    ]


addCurrentFloat : Maybe String -> (item -> Maybe Float) -> Item item -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addCurrentFloat raw getValue itemState attrs =
    case raw of
        Just rawVal ->
            A.value rawVal :: attrs

        Nothing ->
            case itemState of
                Creating _ ->
                    attrs

                Updating _ current ->
                    case getValue current of
                        Nothing ->
                            attrs

                        Just num ->
                            (A.value <| Future.String.fromFloat num) :: attrs


addDefaultFloat : (item -> Maybe Float) -> Item item -> List (Html.Attribute msg) -> List (Html.Attribute msg)
addDefaultFloat getValue itemState attrs =
    case itemState of
        Creating _ ->
            attrs

        Updating original _ ->
            case getValue original of
                Nothing ->
                    attrs

                Just num ->
                    (A.defaultValue <| Future.String.fromFloat num) :: attrs


checkboxField : (item -> Bool) -> Item item -> msg -> FieldMeta -> List (Html msg)
checkboxField getValue itemState toggleMsg meta =
    let
        checked =
            case itemState of
                Creating item ->
                    getValue item

                Updating _ item ->
                    getValue item
    in
    [ Html.div [ Css.flex ]
        [ Html.input
            [ A.id meta.id
            , A.name meta.name
            , A.type_ "checkbox"
            , A.checked checked
            , E.onClick toggleMsg
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


submitButton : Item a -> Html msg
submitButton item =
    let
        txt =
            case item of
                Creating _ ->
                    "Create"

                Updating _ _ ->
                    "Update"
    in
    Html.button
        [ A.id "formSubmitButton"
        , Css.btn
        , Css.btn_purple
        , Css.mt_4
        ]
        [ Html.text txt ]


type alias MultiSelectField msg a b =
    { items : RL.RemoteList { a | pk : Int }
    , getPks : b -> List Int
    , item : Item b
    , filter : Regex.Regex
    , filterMsg : String -> msg
    , itemView : List Int -> { a | pk : Int } -> Html msg
    , selectedView : List Int -> { a | pk : Int } -> Html msg
    }


multiSelectField : MultiSelectField msg a b -> FieldMeta -> List (Html msg)
multiSelectField props meta =
    let
        pks =
            props.getPks (itemGetCurrent props.item)
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
    , selectedPks : List Int
    , itemToKey : { a | pk : Int } -> String
    , toggleMsg : Int -> msg
    , itemToId : { a | pk : Int } -> String
    }


multiSelectItemHelper : MultiSelectItemProps msg { a | pk : Int } -> { a | pk : Int } -> Html msg
multiSelectItemHelper props item =
    Html.Keyed.node "div"
        [ E.onClick <| props.toggleMsg item.pk
        , A.id <| props.itemToId item
        , Css.border_b_2
        , Css.cursor_pointer
        ]
        [ ( props.itemToKey item
          , Html.div []
                [ selectedIcon props.selectedPks item
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


selectedItemsView : List Int -> (List Int -> { a | pk : Int } -> Html msg) -> RL.RemoteList { a | pk : Int } -> List (Html msg)
selectedItemsView pks render rl =
    rl
        |> RL.toList
        |> List.filter (\x -> List.member x.pk pks)
        |> List.map (render pks)


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


showArchiveNotice :
    List { item | is_archived : Bool }
    -> ({ item | is_archived : Bool } -> a)
    -> Form { item | is_archived : Bool } b
    -> Bool
showArchiveNotice items getter form =
    case form of
        Loading ->
            False

        Item404 ->
            False

        Error _ ->
            False

        Saving _ _ ->
            False

        Editing item _ _ ->
            let
                archivedValues =
                    items
                        |> List.filter .is_archived
                        |> List.map getter
            in
            case item of
                Creating current ->
                    List.member (getter current) archivedValues

                Updating original current ->
                    case getter original == getter current of
                        True ->
                            False

                        False ->
                            List.member (getter current) archivedValues



-- Sending SMS Forms


contentField : Int -> { getValue : item -> String, item : Item item, onInput : String -> msg } -> FieldMeta -> List (Html msg)
contentField smsCharLimit data meta =
    longTextField
        (ceiling <| (toFloat smsCharLimit / 160))
        data
        meta



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
