module Pages.Forms.Contact.View exposing (view)

import Data.Recipient exposing (Recipient)
import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (checkboxField, form, simpleTextField, submitButton)
import Html exposing (Html, a, div, p, text)
import Html.Attributes as A
import Messages exposing (FormMsg(ContactFormMsg, PostForm), Msg(FormMsg, Nope))
import Models exposing (Settings)
import Pages exposing (Page(ContactForm))
import Pages.Error404 as E404
import Pages.Forms.Contact.Messages exposing (ContactFormMsg(..))
import Pages.Forms.Contact.Meta exposing (meta)
import Pages.Forms.Contact.Model exposing (ContactFormModel, initialContactFormModel)
import Pages.Forms.Contact.Remote exposing (postCmd)
import Pages.Fragments.Loader exposing (loader)
import RemoteList as RL
import Route exposing (spaLink)


-- Main view


view : Settings -> Maybe (Html Msg) -> Maybe Int -> RL.RemoteList Recipient -> ContactFormModel -> FormStatus -> Html Msg
view settings maybeTable maybePk contacts_ model status =
    case maybePk of
        Nothing ->
            -- creating a new contact:
            creating settings contacts_ model status

        Just pk ->
            -- trying to edit an existing contact:
            editing settings maybeTable pk contacts_ model status


creating : Settings -> RL.RemoteList Recipient -> ContactFormModel -> FormStatus -> Html Msg
creating settings contacts model status =
    viewHelp settings Nothing Nothing contacts model status


editing : Settings -> Maybe (Html Msg) -> Int -> RL.RemoteList Recipient -> ContactFormModel -> FormStatus -> Html Msg
editing settings maybeTable pk contacts model status =
    let
        currentContact =
            contacts
                |> RL.toList
                |> List.filter (\x -> x.pk == pk)
                |> List.head
    in
    case currentContact of
        Just contact ->
            -- contact exists, show the form:
            viewHelp settings maybeTable (Just contact) contacts model status

        Nothing ->
            -- contact does not exist:
            case contacts of
                RL.FinalPageReceived _ ->
                    -- show 404 if we have finished loading
                    E404.view

                _ ->
                    -- show loader while we wait
                    loader


viewHelp : Settings -> Maybe (Html Msg) -> Maybe Recipient -> RL.RemoteList Recipient -> ContactFormModel -> FormStatus -> Html Msg
viewHelp settings maybeTable currentContact contacts_ model status =
    let
        contacts =
            RL.toList contacts_

        showAN =
            showArchiveNotice contacts currentContact model

        fields =
            [ Field meta.first_name <| firstNameField meta.first_name currentContact
            , Field meta.last_name <| lastNameField meta.last_name currentContact
            , Field meta.number <| numberField meta.number settings.defaultNumberPrefix currentContact
            , Field meta.do_not_reply <| doNotReplyField meta.do_not_reply currentContact
            ]
    in
    div []
        [ archiveNotice showAN contacts model.number
        , form status fields (submitMsg settings.csrftoken showAN model currentContact) (submitButton currentContact showAN)
        , Maybe.withDefault (text "") maybeTable
        ]


firstNameField : FieldMeta -> Maybe Recipient -> List (Html Msg)
firstNameField meta_ maybeContact =
    simpleTextField
        meta_
        (Maybe.map .first_name maybeContact)
        (FormMsg << ContactFormMsg << UpdateContactFirstNameField)


lastNameField : FieldMeta -> Maybe Recipient -> List (Html Msg)
lastNameField meta_ maybeContact =
    simpleTextField
        meta_
        (Maybe.map .last_name maybeContact)
        (FormMsg << ContactFormMsg << UpdateContactLastNameField)


numberField : FieldMeta -> String -> Maybe Recipient -> List (Html Msg)
numberField meta_ defaultPrefix maybeContact =
    let
        num =
            case maybeContact of
                Nothing ->
                    Just defaultPrefix

                Just contact ->
                    contact.number
    in
    simpleTextField
        meta_
        num
        (FormMsg << ContactFormMsg << UpdateContactNumberField)


doNotReplyField : FieldMeta -> Maybe Recipient -> List (Html Msg)
doNotReplyField meta_ maybeContact =
    checkboxField
        meta_
        maybeContact
        .do_not_reply
        (FormMsg << ContactFormMsg << UpdateContactDoNotReplyField)


showArchiveNotice : List Recipient -> Maybe Recipient -> ContactFormModel -> Bool
showArchiveNotice contacts maybeContact model =
    let
        originalNum =
            Maybe.map .number maybeContact
                |> Maybe.withDefault Nothing

        currentProposedNum =
            model.number

        archivedNums =
            contacts
                |> List.filter .is_archived
                |> List.map .number
    in
    case originalNum == currentProposedNum of
        True ->
            False

        False ->
            List.member currentProposedNum archivedNums


archiveNotice : Bool -> List Recipient -> Maybe String -> Html Msg
archiveNotice show contacts num =
    let
        matchedContact =
            contacts
                |> List.filter (\c -> c.number == num)
                |> List.head
                |> Maybe.map .pk
    in
    case show of
        False ->
            text ""

        True ->
            div [ A.class "ui message" ]
                [ p [] [ text "There is already a Contact that with that number in the archive" ]
                , p []
                    [ text "Or you can restore the contact here: "
                    , spaLink a [] [ text "Archived Contact" ] <| ContactForm initialContactFormModel matchedContact
                    ]
                ]


submitMsg : CSRFToken -> Bool -> ContactFormModel -> Maybe Recipient -> Msg
submitMsg csrf showAN model maybeContact =
    case showAN of
        True ->
            Nope

        False ->
            FormMsg <| PostForm <| postCmd csrf model maybeContact
