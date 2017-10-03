module Pages.Forms.SendAdhoc.View exposing (view)

import Data exposing (Recipient)
import Date
import DateTimePicker
import FilteringTable exposing (filterInput, filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (contentField, form, sendButton, timeField)
import Helpers exposing (onClick)
import Html exposing (Html, a, div, i, label, p, text)
import Html.Attributes as A
import Html.Keyed
import Messages exposing (FormMsg(PostForm, SendAdhocMsg), Msg(FormMsg))
import Models exposing (Model, Settings)
import Pages exposing (Page(ContactForm))
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.Forms.SendAdhoc.Messages exposing (SendAdhocMsg(ToggleSelectedContact, UpdateAdhocFilter, UpdateContent, UpdateDate))
import Pages.Forms.SendAdhoc.Meta exposing (meta)
import Pages.Forms.SendAdhoc.Model exposing (SendAdhocModel)
import Pages.Forms.SendAdhoc.Remote exposing (postCmd)
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (spaLink)


-- Form


view : Settings -> SendAdhocModel -> RL.RemoteList Recipient -> FormStatus -> Html Msg
view settings model contacts status =
    div []
        [ case contacts of
            RL.FinalPageReceived contacts_ ->
                if List.length contacts_ == 0 then
                    noContacts
                else
                    sendForm settings model contacts status

            _ ->
                sendForm settings model contacts status
        ]


noContacts : Html Msg
noContacts =
    div [ A.class "segment" ]
        [ p [] [ text "Looks like you don't have any contacts yet." ]
        , spaLink a [ A.class "button" ] [ text "Add a New Contact" ] <| ContactForm initialContactFormModel Nothing
        ]


sendForm : Settings -> SendAdhocModel -> RL.RemoteList Recipient -> FormStatus -> Html Msg
sendForm settings model contacts status =
    let
        fields =
            [ Field meta.content <| contentField meta.content settings.smsCharLimit (FormMsg << SendAdhocMsg << UpdateContent) model.content
            , Field meta.recipients <| contactsField meta.recipients model contacts
            , Field meta.scheduled_time <| timeField updateSADate meta.scheduled_time model.datePickerState model.date
            ]
                |> List.map FormField
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields (FormMsg <| PostForm <| postCmd settings.csrftoken settings.userPerms model) (sendButton model.cost)
        ]


updateSADate : DateTimePicker.State -> Maybe Date.Date -> Msg
updateSADate state maybeDate =
    FormMsg <| SendAdhocMsg <| UpdateDate state maybeDate



-- Contacts Dropdown


loadingMessage : RL.RemoteList a -> Html Msg
loadingMessage rl =
    case rl of
        RL.NotAsked _ ->
            text ""

        RL.FinalPageReceived _ ->
            text ""

        RL.RespFailed err _ ->
            div [ A.class "alert" ] [ text err ]

        RL.WaitingForFirstResp _ ->
            div [ A.class "alert" ] [ text "We are fetching your contacts now..." ]

        RL.WaitingForPage _ ->
            div [ A.class "alert" ] [ text "We are fetching your contacts now..." ]

        RL.WaitingOnRefresh _ ->
            text ""


contactsField : FieldMeta -> SendAdhocModel -> RL.RemoteList Recipient -> List (Html Msg)
contactsField meta_ model contacts =
    [ label [ A.for meta_.id ] [ text meta_.label ]
    , div [ A.class "segment" ]
        [ loadingMessage contacts
        , selectedContacts model.selectedContacts contacts
        , filterInput (FormMsg << SendAdhocMsg << UpdateAdhocFilter)
        , div
            [ A.class "list"
            , A.style
                [ "min-height" => "25vh"
                , "max-height" => "50vh"
                , "overflow-y" => "auto"
                ]
            ]
            (contacts
                |> RL.toList
                |> List.filter (filterRecord model.adhocFilter)
                |> List.map (contactItem model.selectedContacts)
            )
        ]
    ]


selectedContacts : List Int -> RL.RemoteList Recipient -> Html Msg
selectedContacts selectedPks contacts_ =
    let
        selected =
            contacts_
                |> RL.toList
                |> List.filter (\c -> List.member c.pk selectedPks)
                |> List.map contactLabel
    in
    Html.div [ A.style [ "margin-bottom" => "1rem" ] ] selected


contactLabel : Recipient -> Html Msg
contactLabel contact =
    Html.div
        [ A.class "badge"
        , A.style [ "user-select" => "none" ]
        , onClick <| FormMsg <| SendAdhocMsg <| ToggleSelectedContact contact.pk
        ]
        [ Html.text contact.full_name ]


contactItem : List Int -> Recipient -> Html Msg
contactItem selectedPks contact =
    Html.Keyed.node "div"
        [ A.class "item"
        , onClick <| FormMsg <| SendAdhocMsg <| ToggleSelectedContact contact.pk
        , A.id "contactItem"
        ]
        [ ( toString contact.pk, contactItemHelper selectedPks contact ) ]


contactItemHelper : List Int -> Recipient -> Html Msg
contactItemHelper selectedPks contact =
    div [ A.style [ "color" => "#000" ] ]
        [ selectedIcon selectedPks contact
        , text contact.full_name
        ]


selectedIcon : List Int -> Recipient -> Html Msg
selectedIcon selectedPks contact =
    case List.member contact.pk selectedPks of
        False ->
            text ""

        True ->
            i [ A.class "fa fa-check", A.style [ "color" => "var(--color-purple)" ] ] []
