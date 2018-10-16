module Pages.Forms.Group exposing (Model, Msg(..), init, initialModel, update, view)

import Css
import Data exposing (RecipientGroup, RecipientSimple)
import DjangoSend
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Form as F
import Helpers exposing (onClick, userFacingErrorMessage)
import Html exposing (Html)
import Html.Attributes as A
import Http
import Json.Encode as Encode
import Pages.Forms.Meta.Group exposing (meta)
import Regex
import RemoteList as RL
import Urls


init : Model -> Cmd Msg
init { maybePk } =
    case maybePk of
        Just _ ->
            Http.get (Urls.api_recipient_groups maybePk) (Data.decodeListToItem Data.decodeRecipientGroup)
                |> Http.send ReceiveInitialData

        Nothing ->
            Cmd.none


type alias Model =
    { form : F.Form RecipientGroup DirtyState
    , maybePk : Maybe Int
    }


initialModel : Maybe Int -> Model
initialModel maybePk =
    case maybePk of
        Just _ ->
            { form = F.formLoading
            , maybePk = maybePk
            }

        Nothing ->
            { form = F.startCreating defaultGroup initialDirtyState
            , maybePk = maybePk
            }


type alias DirtyState =
    { membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    }


initialDirtyState : DirtyState
initialDirtyState =
    { membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    }


defaultGroup : RecipientGroup
defaultGroup =
    { name = ""
    , pk = 0
    , description = ""
    , members = []
    , nonmembers = []
    , cost = 0
    , is_archived = False
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })
    | ReceiveInitialData (Result Http.Error (Maybe RecipientGroup))


type InputMsg
    = UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | UpdateGroupNameField String
    | UpdateGroupDescField String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    , groups : RL.RemoteList RecipientGroup
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        ReceiveInitialData (Ok (Just group)) ->
            F.UpdateResp
                { model | form = F.startUpdating group initialDirtyState }
                Cmd.none
                []
                Nothing

        ReceiveInitialData (Ok Nothing) ->
            F.UpdateResp
                { model | form = F.to404 }
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
                (F.setInProgress model)
                (postGroupCmd
                    props.csrftoken
                    model
                    (RL.filter (\x -> Just x.pk == model.maybePk) props.groups
                        |> RL.toList
                        |> List.head
                    )
                )
                []
                Nothing

        ReceiveFormResp (Ok resp) ->
            F.okFormRespUpdate props resp model

        ReceiveFormResp (Err err) ->
            F.errFormRespUpdate err model


updateInput : InputMsg -> RecipientGroup -> DirtyState -> ( RecipientGroup, DirtyState )
updateInput msg model dirty =
    case msg of
        UpdateMemberFilter text ->
            ( model, { dirty | membersFilterRegex = textToRegex text } )

        UpdateNonMemberFilter text ->
            ( model, { dirty | nonmembersFilterRegex = textToRegex text } )

        UpdateGroupDescField text ->
            ( { model | description = text }, dirty )

        UpdateGroupNameField text ->
            ( { model | name = text }, dirty )


postGroupCmd : DjangoSend.CSRFToken -> Model -> Maybe RecipientGroup -> Cmd Msg
postGroupCmd csrf { maybePk, form } maybeGroup =
    case F.getCurrent form of
        Just item ->
            let
                body =
                    [ ( "name", Encode.string item.name )
                    , ( "description", Encode.string item.description )
                    ]
                        |> F.addPk maybePk
            in
            DjangoSend.rawPost csrf (Urls.api_recipient_groups Nothing) body
                |> Http.send ReceiveFormResp

        Nothing ->
            Cmd.none



-- View


type alias Props msg =
    { form : InputMsg -> msg
    , postForm : msg
    , noop : msg
    , toggleGroupMembership : RecipientGroup -> RecipientSimple -> msg
    , restoreGroupLink : Maybe Int -> Html msg
    , groups : RL.RemoteList RecipientGroup
    }


view : Props msg -> Model -> Html msg
view props model =
    let
        groups =
            RL.toList props.groups

        showAN =
            F.showArchiveNotice groups .name model.form

        maybeCurrent =
            F.getCurrent model.form

        areCreating =
            case F.getOriginal model.form of
                Nothing ->
                    True

                Just _ ->
                    False
    in
    Html.div []
        [ archiveNotice props showAN groups (Maybe.map .name maybeCurrent)
        , F.form
            model.form
            (fieldsHelp props)
            (submitMsg props showAN)
            F.submitButton
        , membershipToggles props (not (areCreating || showAN)) maybeCurrent (F.getDirty model.form)
        ]


fieldsHelp : Props msg -> F.Item RecipientGroup -> DirtyState -> List (F.FormItem msg)
fieldsHelp props item _ =
    [ F.Field meta.name (nameField props item)
    , F.Field meta.description (descField props item)
    ]
        |> List.map F.FormField


archiveNotice : Props msg -> Bool -> List RecipientGroup -> Maybe String -> Html msg
archiveNotice props show groups name =
    let
        matchedGroup =
            groups
                |> List.filter (\g -> g.name == Maybe.withDefault "" name)
                |> List.head
                |> Maybe.map .pk
    in
    case show of
        False ->
            Html.text ""

        True ->
            Html.div [ Css.alert, Css.alert_info ]
                [ Html.p [] [ Html.text "There is already a Group that with that name in the archive" ]
                , Html.p [] [ Html.text "You can chose a different name." ]
                , Html.p []
                    [ Html.text "Or you can restore the group here: "
                    , props.restoreGroupLink matchedGroup
                    ]
                ]


nameField : Props msg -> F.Item RecipientGroup -> (F.FieldMeta -> List (Html msg))
nameField props item =
    F.simpleTextField
        { getValue = .name
        , item = item
        , onInput = props.form << UpdateGroupNameField
        }


descField : Props msg -> F.Item RecipientGroup -> (F.FieldMeta -> List (Html msg))
descField props item =
    F.simpleTextField
        { getValue = .description
        , item = item
        , onInput = props.form << UpdateGroupDescField
        }


submitMsg : Props msg -> Bool -> msg
submitMsg props showAN =
    case showAN of
        True ->
            props.noop

        False ->
            props.postForm


membershipToggles : Props msg -> Bool -> Maybe RecipientGroup -> Maybe DirtyState -> Html msg
membershipToggles props shouldShow maybeGroup maybeDirty =
    case ( shouldShow, maybeGroup, maybeDirty ) of
        ( True, Just group, Just dirty ) ->
            let
                groupFromStore =
                    getGroupFromStore props.groups group
            in
            Html.div [ Css.max_w_md, Css.mx_auto ]
                [ Html.br [] []
                , Html.h3 [ Css.mb_2 ] [ Html.text "Group Members" ]
                , Html.p [ Css.mb_2 ] [ Html.text "Click a person to toggle their membership." ]
                , Html.div [ Css.flex ]
                    [ Html.div [ Css.flex_1 ]
                        [ Html.h4 [] [ Html.text "Non-Members" ]
                        , Html.div []
                            [ filterInput (props.form << UpdateNonMemberFilter)
                            , cardContainer props "nonmembers" dirty.nonmembersFilterRegex groupFromStore.nonmembers groupFromStore
                            ]
                        ]
                    , Html.div [ Css.flex_1 ]
                        [ Html.h4 [] [ Html.text "Members" ]
                        , Html.div []
                            [ filterInput (props.form << UpdateMemberFilter)
                            , cardContainer props "members" dirty.membersFilterRegex groupFromStore.members groupFromStore
                            ]
                        ]
                    ]
                ]

        ( _, _, _ ) ->
            Html.div [] []


getGroupFromStore : RL.RemoteList RecipientGroup -> RecipientGroup -> RecipientGroup
getGroupFromStore rl group =
    rl
        |> RL.toList
        |> List.filter (\g -> g.name == group.name)
        |> List.head
        |> Maybe.withDefault group


cardContainer : Props msg -> String -> Regex.Regex -> List RecipientSimple -> RecipientGroup -> Html msg
cardContainer props id_ filterRegex contacts group =
    Html.div [ Css.px_2 ]
        [ Html.br [] []
        , Html.div [ A.id <| id_ ++ "_list" ]
            (contacts
                |> List.filter (filterRecord filterRegex)
                |> List.map (card props id_ group)
            )
        ]


card : Props msg -> String -> RecipientGroup -> RecipientSimple -> Html msg
card props id_ group contact =
    Html.div [ A.id <| id_ ++ "_item", Css.border_b_2, Css.select_none, Css.cursor_pointer ]
        [ Html.div [ onClick (props.toggleGroupMembership group contact) ]
            [ Html.text contact.full_name ]
        ]
