module Pages.Forms.Group exposing (Model, Msg(..), initialModel, update, view)

import Css
import Data exposing (RecipientGroup, RecipientSimple)
import DjangoSend
import FilteringTable exposing (filterInput, filterRecord, textToRegex)
import Form as F exposing (..)
import Helpers exposing (onClick)
import Html exposing (Html)
import Html.Attributes as A
import Http
import Json.Encode as Encode
import Pages.Error404 as E404
import Pages.Forms.Meta.Group exposing (meta)
import Pages.Fragments.Loader exposing (loader)
import Regex
import RemoteList as RL
import Urls


type alias Model =
    { membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    , name : Maybe String
    , description : Maybe String
    , formStatus : FormStatus
    }


initialModel : Model
initialModel =
    { membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    , name = Nothing
    , description = Nothing
    , formStatus = NoAction
    }



-- Update


type Msg
    = InputMsg InputMsg
    | PostForm
    | ReceiveFormResp (Result Http.Error { body : String, code : Int })


type InputMsg
    = UpdateMemberFilter String
    | UpdateNonMemberFilter String
    | UpdateGroupNameField String
    | UpdateGroupDescField String


type alias UpdateProps =
    { csrftoken : DjangoSend.CSRFToken
    , successPageUrl : String
    , maybePk : Maybe Int
    , groups : RL.RemoteList RecipientGroup
    }


update : UpdateProps -> Msg -> Model -> F.UpdateResp Msg Model
update props msg model =
    case msg of
        InputMsg inputMsg ->
            F.UpdateResp
                (updateInput inputMsg model)
                Cmd.none
                []
                Nothing

        PostForm ->
            F.UpdateResp
                (F.setInProgress model)
                (postGroupCmd
                    props.csrftoken
                    model
                    (RL.filter (\x -> Just x.pk == props.maybePk) props.groups
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


updateInput : InputMsg -> Model -> Model
updateInput msg model =
    case msg of
        UpdateMemberFilter text ->
            { model | membersFilterRegex = textToRegex text }

        UpdateNonMemberFilter text ->
            { model | nonmembersFilterRegex = textToRegex text }

        UpdateGroupDescField text ->
            { model | description = Just text }

        UpdateGroupNameField text ->
            { model | name = Just text }


postGroupCmd : DjangoSend.CSRFToken -> Model -> Maybe RecipientGroup -> Cmd Msg
postGroupCmd csrf model maybeGroup =
    let
        body =
            [ ( "name", Encode.string <| F.extractField .name model.name maybeGroup )
            , ( "description", Encode.string <| F.extractField .description model.description maybeGroup )
            ]
                |> F.addPk maybeGroup
    in
    DjangoSend.rawPost csrf (Urls.api_recipient_groups Nothing) body
        |> Http.send ReceiveFormResp



-- View


type alias Props msg =
    { form : InputMsg -> msg
    , postForm : msg
    , noop : msg
    , toggleGroupMembership : RecipientGroup -> RecipientSimple -> msg
    , restoreGroupLink : Maybe Int -> Html msg
    , groups : RL.RemoteList RecipientGroup
    }


view : Props msg -> Maybe Int -> Model -> Html msg
view props maybePk model =
    case maybePk of
        Nothing ->
            -- creating a new group
            creating props model

        Just pk ->
            -- trying to edit an existing group:
            editing props pk model


creating : Props msg -> Model -> Html msg
creating props model =
    viewHelp props Nothing model


editing : Props msg -> Int -> Model -> Html msg
editing props pk model =
    let
        currentGroup =
            props.groups
                |> RL.toList
                |> List.filter (\x -> x.pk == pk)
                |> List.head
    in
    case currentGroup of
        Just grp ->
            -- group exists, show the form:
            viewHelp props (Just grp) model

        Nothing ->
            -- group does not exist:
            case props.groups of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Props msg -> Maybe RecipientGroup -> Model -> Html msg
viewHelp props currentGroup model =
    let
        groups =
            RL.toList props.groups

        showAN =
            showArchiveNotice groups currentGroup model

        fields =
            [ Field meta.name (nameField props currentGroup)
            , Field meta.description (descField props currentGroup)
            ]
                |> List.map FormField
    in
    Html.div []
        [ archiveNotice props showAN groups model.name
        , form model.formStatus fields (submitMsg props showAN) (submitButton currentGroup)
        , membershipToggles props currentGroup model
        ]


showArchiveNotice : List RecipientGroup -> Maybe RecipientGroup -> Model -> Bool
showArchiveNotice groups maybeGroup model =
    let
        originalName =
            Maybe.map .name maybeGroup
                |> Maybe.withDefault ""

        currentProposedName =
            model.name
                |> Maybe.withDefault ""

        archivedNames =
            groups
                |> List.filter .is_archived
                |> List.map .name
    in
    case originalName == currentProposedName of
        True ->
            False

        False ->
            List.member currentProposedName archivedNames


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


nameField : Props msg -> Maybe RecipientGroup -> (FieldMeta -> List (Html msg))
nameField props maybeGroup =
    simpleTextField
        (Maybe.map .name maybeGroup)
        (props.form << UpdateGroupNameField)


descField : Props msg -> Maybe RecipientGroup -> (FieldMeta -> List (Html msg))
descField props maybeGroup =
    simpleTextField
        (Maybe.map .description maybeGroup)
        (props.form << UpdateGroupDescField)


submitMsg : Props msg -> Bool -> msg
submitMsg props showAN =
    case showAN of
        True ->
            props.noop

        False ->
            props.postForm


membershipToggles : Props msg -> Maybe RecipientGroup -> Model -> Html msg
membershipToggles props maybeGroup model =
    case maybeGroup of
        Nothing ->
            Html.div [] []

        Just group ->
            Html.div [ Css.max_w_md, Css.mx_auto ]
                [ Html.br [] []
                , Html.h3 [ Css.mb_2 ] [ Html.text "Group Members" ]
                , Html.p [ Css.mb_2 ] [ Html.text "Click a person to toggle their membership." ]
                , Html.div [ Css.flex ]
                    [ Html.div [ Css.flex_1 ]
                        [ Html.h4 [] [ Html.text "Non-Members" ]
                        , Html.div []
                            [ filterInput (props.form << UpdateNonMemberFilter)
                            , cardContainer props "nonmembers" model.nonmembersFilterRegex group.nonmembers group
                            ]
                        ]
                    , Html.div [ Css.flex_1 ]
                        [ Html.h4 [] [ Html.text "Members" ]
                        , Html.div []
                            [ filterInput (props.form << UpdateMemberFilter)
                            , cardContainer props "members" model.membersFilterRegex group.members group
                            ]
                        ]
                    ]
                ]


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
