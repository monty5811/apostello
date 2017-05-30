module Pages.ContactForm.View exposing (view)

import Data.Recipient exposing (Recipient)
import Data.Store as Store
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (checkboxField, form, simpleTextField, submitButton)
import Html exposing (Html, a, div, p, text)
import Html.Attributes as A
import Messages exposing (FormMsg(PostContactForm), Msg(ContactFormMsg, FormMsg, Nope))
import Models exposing (Settings)
import Pages exposing (Page(ContactForm))
import Pages.ContactForm.Messages exposing (ContactFormMsg(..))
import Pages.ContactForm.Meta exposing (meta)
import Pages.ContactForm.Model exposing (ContactFormModel, initialContactFormModel)
import Route exposing (spaLink)


-- Main view


view : Settings -> Maybe (Html Msg) -> Maybe Int -> Store.RemoteList Recipient -> ContactFormModel -> FormStatus -> Html Msg
view settings maybeTable maybePk contacts_ model status =
    let
        contacts =
            Store.toList contacts_

        pk =
            Maybe.withDefault 0 maybePk

        currentContact =
            contacts
                |> List.filter (\x -> x.pk == pk)
                |> List.head

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
        , form status fields (submitMsg showAN model currentContact) (submitButton currentContact showAN)
        , Maybe.withDefault (text "") maybeTable
        ]


firstNameField : FieldMeta -> Maybe Recipient -> List (Html Msg)
firstNameField meta_ maybeContact =
    simpleTextField
        meta_
        (Maybe.map .first_name maybeContact)
        (ContactFormMsg << UpdateContactFirstNameField)


lastNameField : FieldMeta -> Maybe Recipient -> List (Html Msg)
lastNameField meta_ maybeContact =
    simpleTextField
        meta_
        (Maybe.map .last_name maybeContact)
        (ContactFormMsg << UpdateContactLastNameField)


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
        (ContactFormMsg << UpdateContactNumberField)


doNotReplyField : FieldMeta -> Maybe Recipient -> List (Html Msg)
doNotReplyField meta_ maybeContact =
    checkboxField
        meta_
        maybeContact
        .do_not_reply
        (ContactFormMsg << UpdateContactDoNotReplyField)


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


submitMsg : Bool -> ContactFormModel -> Maybe Recipient -> Msg
submitMsg showAN model maybeContact =
    case showAN of
        True ->
            Nope

        False ->
            FormMsg <| PostContactForm model maybeContact
