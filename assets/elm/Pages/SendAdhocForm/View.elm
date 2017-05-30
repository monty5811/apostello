module Pages.SendAdhocForm.View exposing (view)

import Data.Recipient exposing (Recipient)
import Data.Store as Store
import Date
import DateTimePicker
import FilteringTable exposing (filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (form)
import Forms.View.Send exposing (contentField, sendButton, timeField)
import Helpers exposing (onClick)
import Html exposing (Html, a, br, div, i, input, label, p, text)
import Html.Attributes as A
import Html.Events as E
import Html.Keyed
import Messages exposing (FormMsg(PostAdhocForm), Msg(FormMsg, SendAdhocMsg))
import Models exposing (Model, Settings)
import Pages exposing (Page(ContactForm))
import Pages.ContactForm.Model exposing (initialContactFormModel)
import Pages.SendAdhocForm.Messages exposing (SendAdhocMsg(ToggleSelectedContact, UpdateAdhocFilter, UpdateContent, UpdateDate))
import Pages.SendAdhocForm.Meta exposing (meta)
import Pages.SendAdhocForm.Model exposing (SendAdhocModel)
import Route exposing (spaLink)


-- Form


view : Settings -> SendAdhocModel -> Store.RemoteList Recipient -> FormStatus -> Html Msg
view settings model contacts status =
    div []
        [ br [] []
        , case contacts of
            Store.FinalPageReceived contacts_ ->
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


sendForm : Settings -> SendAdhocModel -> Store.RemoteList Recipient -> FormStatus -> Html Msg
sendForm settings model contacts status =
    let
        fields =
            [ Field meta.content <| contentField meta.content settings.smsCharLimit (SendAdhocMsg << UpdateContent) model.content
            , Field meta.recipients <| contactsField meta.recipients model contacts
            , Field meta.scheduled_time <| timeField updateSADate meta.scheduled_time model.datePickerState model.date
            ]
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields (FormMsg <| PostAdhocForm model) (sendButton model.cost)
        ]


updateSADate : DateTimePicker.State -> Maybe Date.Date -> Msg
updateSADate state maybeDate =
    SendAdhocMsg <| UpdateDate state maybeDate



-- Contacts Dropdown


loadingMessage : Store.RemoteList a -> Html Msg
loadingMessage rl =
    case rl of
        Store.NotAsked _ ->
            text ""

        Store.FinalPageReceived _ ->
            text ""

        Store.RespFailed err _ ->
            div [ A.class "ui secondary segment" ] [ text err ]

        Store.WaitingForFirstResp _ ->
            div [ A.class "ui secondary segment" ] [ text "We are fetching your contacts now..." ]

        Store.WaitingForPage _ ->
            div [ A.class "ui secondary segment" ] [ text "We are fetching your contacts now..." ]

        Store.WaitingOnRefresh _ ->
            text ""


contactsField : FieldMeta -> SendAdhocModel -> Store.RemoteList Recipient -> List (Html Msg)
contactsField meta model contacts =
    [ label [ A.for meta.id ] [ text meta.label ]
    , div [ A.class "ui raised segment" ]
        [ loadingMessage contacts
        , div [ A.class "ui left icon large transparent fluid input" ]
            [ input
                [ A.placeholder "Filter..."
                , A.type_ "text"
                , E.onInput (Messages.SendAdhocMsg << UpdateAdhocFilter)
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
                |> Store.toList
                |> List.filter (filterRecord model.adhocFilter)
                |> List.map (contactItem model.selectedContacts)
            )
        ]
    ]


contactItem : List Int -> Recipient -> Html Msg
contactItem selectedPks contact =
    Html.Keyed.node "div"
        [ A.class "item", onClick <| Messages.SendAdhocMsg <| ToggleSelectedContact contact.pk ]
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
