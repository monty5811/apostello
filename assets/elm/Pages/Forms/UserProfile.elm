module Pages.Forms.UserProfile exposing (Model, Msg(..), init, initialModel, update, view)

import Css
import Data exposing (UserProfile, decodeUserProfile)
import DjangoSend
import Form as F
import Helpers exposing (userFacingErrorMessage)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Pages.Forms.Meta.UserProfile exposing (meta)
import RemoteList as RL
import Urls


init : Int -> Cmd Msg
init pk =
    Http.get (Urls.api_user_profile pk) (decodeSingleItem decodeUserProfile)
        |> Http.send ReceiveInitialData


decodeSingleItem : Decode.Decoder a -> Decode.Decoder a
decodeSingleItem decoder =
    Decode.field "results" (Decode.list decoder)
        |> Decode.andThen
            (\l ->
                case l of
                    [ item ] ->
                        Decode.succeed item

                    _ ->
                        Decode.fail "Bad payload"
            )


type alias Model =
    { pk : Int
    , form : F.Form UserProfile DirtyState
    }


type alias DirtyState =
    { message_cost_limit : Maybe String }


initialModel : Int -> Model
initialModel pk =
    { pk = pk
    , form = F.formLoading
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveInitialData (Result Http.Error UserProfile)
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type InputMsg
    = UpdateApproved
    | UpdateMessageCostLimit String
    | UpdateCanSeeGroups
    | UpdateCanSeeContactNames
    | UpdateCanSeeKeywords
    | UpdateCanSeeOutgoing
    | UpdateCanSeeIncoming
    | UpdateCanSendSms
    | UpdateCanSeeContactNums
    | UpdateCanSeeContactNotes
    | UpdateCanImport
    | UpdateCanArchive


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    , userprofiles : RL.RemoteList UserProfile
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        ReceiveInitialData (Ok profile) ->
            F.UpdateResp
                { model | form = F.startUpdating profile (DirtyState Nothing) }
                Cmd.none
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
                model
                (postCmd
                    props.csrftoken
                    model
                )
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> UserProfile -> DirtyState -> ( UserProfile, DirtyState )
updateInput msg profile raw =
    case msg of
        UpdateApproved ->
            ( { profile | approved = not profile.approved }, raw )

        UpdateCanSeeGroups ->
            ( { profile | can_see_groups = not profile.can_see_groups }, raw )

        UpdateCanSeeContactNames ->
            ( { profile | can_see_contact_names = not profile.can_see_contact_names }, raw )

        UpdateCanSeeKeywords ->
            ( { profile | can_see_keywords = not profile.can_see_keywords }, raw )

        UpdateCanSeeOutgoing ->
            ( { profile | can_see_outgoing = not profile.can_see_outgoing }, raw )

        UpdateCanSeeIncoming ->
            ( { profile | can_see_incoming = not profile.can_see_incoming }, raw )

        UpdateCanSendSms ->
            ( { profile | can_send_sms = not profile.can_send_sms }, raw )

        UpdateCanSeeContactNums ->
            ( { profile | can_see_contact_nums = not profile.can_see_contact_nums }, raw )

        UpdateCanSeeContactNotes ->
            ( { profile | can_see_contact_notes = not profile.can_see_contact_notes }, raw )

        UpdateCanImport ->
            ( { profile | can_import = not profile.can_import }, raw )

        UpdateCanArchive ->
            ( { profile | can_archive = not profile.can_archive }, raw )

        UpdateMessageCostLimit text ->
            case String.toFloat text of
                Ok num ->
                    ( { profile | message_cost_limit = num }, { raw | message_cost_limit = Just text } )

                Err _ ->
                    ( profile, { raw | message_cost_limit = Just text } )


postCmd : DjangoSend.CSRFToken -> Model -> Cmd Msg
postCmd csrf model =
    case F.getCurrent model.form of
        Just user ->
            DjangoSend.rawPost csrf Urls.api_user_profiles (toBody user)
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none


toBody : UserProfile -> List ( String, Encode.Value )
toBody profile =
    [ ( "approved", Encode.bool profile.approved )
    , ( "message_cost_limit", Encode.float profile.message_cost_limit )
    , ( "can_see_groups", Encode.bool profile.can_see_groups )
    , ( "can_see_contact_names", Encode.bool profile.can_see_contact_names )
    , ( "can_see_keywords", Encode.bool profile.can_see_keywords )
    , ( "can_see_outgoing", Encode.bool profile.can_see_outgoing )
    , ( "can_see_incoming", Encode.bool profile.can_see_incoming )
    , ( "can_send_sms", Encode.bool profile.can_send_sms )
    , ( "can_see_contact_nums", Encode.bool profile.can_see_contact_nums )
    , ( "can_see_contact_notes", Encode.bool profile.can_see_contact_notes )
    , ( "can_import", Encode.bool profile.can_import )
    , ( "can_archive", Encode.bool profile.can_archive )
    , ( "pk", Encode.int profile.pk )
    ]


getNewBool : Maybe Bool -> Maybe Bool -> Maybe Bool
getNewBool modelVal profileVal =
    case modelVal of
        Just curVal ->
            -- we have edited the form, toggle the val
            Just <| not curVal

        Nothing ->
            -- we have not edited the F.form yet, toggle if we have a saved profile
            Maybe.map not profileVal



-- View


type alias Messages msg =
    { inputChange : InputMsg -> msg
    , postForm : msg
    }


view : Messages msg -> Model -> Html msg
view msgs model =
    Html.div []
        [ heading model.form
        , F.form
            model.form
            (fieldsHelp msgs)
            msgs.postForm
            F.submitButton
        ]


heading : F.Form UserProfile DirtyState -> Html msg
heading form =
    case F.getCurrent form of
        Just profile ->
            Html.h3 [ Css.max_w_md, Css.mx_auto ] [ Html.text <| "User Profile: " ++ profile.user.email ]

        Nothing ->
            Html.text ""


fieldsHelp : Messages msg -> F.Item UserProfile -> DirtyState -> List (F.FormItem msg)
fieldsHelp msgs item tmpState =
    [ F.Field meta.approved (checkboxField_ item .approved (msgs.inputChange UpdateApproved))
    , F.Field meta.message_cost_limit
        (F.simpleFloatField
            { getValue = .message_cost_limit >> Just
            , item = item
            , tmpState = tmpState.message_cost_limit
            , onInput = msgs.inputChange << UpdateMessageCostLimit
            }
        )
    , F.Field meta.can_see_groups (checkboxField_ item .can_see_groups (msgs.inputChange UpdateCanSeeGroups))
    , F.Field meta.can_see_contact_names (checkboxField_ item .can_see_contact_names (msgs.inputChange UpdateCanSeeContactNames))
    , F.Field meta.can_see_keywords (checkboxField_ item .can_see_keywords (msgs.inputChange UpdateCanSeeKeywords))
    , F.Field meta.can_see_outgoing (checkboxField_ item .can_see_outgoing (msgs.inputChange UpdateCanSeeOutgoing))
    , F.Field meta.can_see_incoming (checkboxField_ item .can_see_incoming (msgs.inputChange UpdateCanSeeIncoming))
    , F.Field meta.can_send_sms (checkboxField_ item .can_send_sms (msgs.inputChange UpdateCanSendSms))
    , F.Field meta.can_see_contact_nums (checkboxField_ item .can_see_contact_nums (msgs.inputChange UpdateCanSeeContactNums))
    , F.Field meta.can_see_contact_notes (checkboxField_ item .can_see_contact_notes (msgs.inputChange UpdateCanSeeContactNotes))
    , F.Field meta.can_import (checkboxField_ item .can_import (msgs.inputChange UpdateCanImport))
    , F.Field meta.can_archive (checkboxField_ item .can_archive (msgs.inputChange UpdateCanArchive))
    ]
        |> List.map F.FormField


checkboxField_ : F.Item UserProfile -> (UserProfile -> Bool) -> msg -> F.FieldMeta -> List (Html msg)
checkboxField_ item fn toggleMsg meta =
    F.checkboxField
        fn
        item
        toggleMsg
        meta
