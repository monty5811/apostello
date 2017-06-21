module Pages.Forms.SendAdhoc.View exposing (view)

import Data.Recipient exposing (Recipient)
import Date
import DateTimePicker
import FilteringTable.Util exposing (filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (form)
import Forms.View.Send exposing (contentField, sendButton, timeField)
import Helpers exposing (onClick)
import Html exposing (Html, a, br, div, i, input, label, p, text)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Messages exposing (FormMsg(PostForm, SendAdhocMsg), Msg(FormMsg))
import Models exposing (Model, Settings)
import Pages exposing (Page(ContactForm))
import Pages.Forms.Contact.Model exposing (initialContactFormModel)
import Pages.Forms.SendAdhoc.Messages exposing (SendAdhocMsg(ToggleSelectedContact, UpdateAdhocFilter, UpdateContent, UpdateDate))
import Pages.Forms.SendAdhoc.Meta exposing (meta)
import Pages.Forms.SendAdhoc.Model exposing (SendAdhocModel)
import Pages.Forms.SendAdhoc.Remote exposing (postCmd)
import Route exposing (spaLink)
import RemoteList as RL


-- Form


view : Settings -> SendAdhocModel -> RL.RemoteList Recipient -> FormStatus -> Html Msg
view settings model contacts status =
    div []
        [ br [] []
        , case contacts of
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
    div [ A.class "ui raised segment" ]
        [ p [] [ text "Looks like you don't have any contacts yet." ]
        , spaLink a [ A.class "ui violet button" ] [ text "Add a New Contact" ] <| ContactForm initialContactFormModel Nothing
        ]


sendForm : Settings -> SendAdhocModel -> RL.RemoteList Recipient -> FormStatus -> Html Msg
sendForm settings model contacts status =
    let
        fields =
            [ Field meta.content <| contentField meta.content settings.smsCharLimit (FormMsg << SendAdhocMsg << UpdateContent) model.content
            , Field meta.recipients <| contactsField meta.recipients model contacts
            , Field meta.scheduled_time <| timeField updateSADate meta.scheduled_time model.datePickerState model.date
            ]
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields (FormMsg <| PostForm <| postCmd settings.csrftoken model) (sendButton model.cost)
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
            div [ A.class "ui secondary segment" ] [ text err ]

        RL.WaitingForFirstResp _ ->
            div [ A.class "ui secondary segment" ] [ text "We are fetching your contacts now..." ]

        RL.WaitingForPage _ ->
            div [ A.class "ui secondary segment" ] [ text "We are fetching your contacts now..." ]

        RL.WaitingOnRefresh _ ->
            text ""


contactsField : FieldMeta -> SendAdhocModel -> RL.RemoteList Recipient -> List (Html Msg)
contactsField meta_ model contacts =
    [ label [ A.for meta_.id ] [ text meta_.label ]
    , div [ A.class "ui raised segment" ]
        [ loadingMessage contacts
        , div [ A.class "ui left icon large transparent fluid input" ]
            [ input
                [ A.placeholder "Filter..."
                , A.type_ "text"
                , E.onInput (FormMsg << SendAdhocMsg << UpdateAdhocFilter)
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
            (contacts
                |> RL.toList
                |> List.filter (filterRecord model.adhocFilter)
                |> List.map (contactItem model.selectedContacts)
            )
        ]
    ]


contactItem : List Int -> Recipient -> Html Msg
contactItem selectedPks contact =
    Html.Keyed.node "div"
        [ A.class "item", onClick <| FormMsg <| SendAdhocMsg <| ToggleSelectedContact contact.pk ]
        [ ( toString contact.pk, contactItemHelper selectedPks contact ) ]


contactItemHelper : List Int -> Recipient -> Html Msg
contactItemHelper selectedPks contact =
    div [ A.class "content", A.style [ ( "color", "#000" ) ] ]
        [ selectedIcon selectedPks contact
        , text contact.full_name
        ]


selectedIcon : List Int -> Recipient -> Html Msg
selectedIcon selectedPks contact =
    case List.member contact.pk selectedPks of
        False ->
            text ""

        True ->
            i [ A.class "check icon", A.style [ ( "color", "#603cba" ) ] ] []
