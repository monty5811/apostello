module View.SendAdhoc exposing (view)

import Html exposing (Html, br, text, i, p, input, label, a, div)
import Html.Attributes exposing (class, style, type_, placeholder, for, href)
import Html.Events exposing (onInput, onSubmit)
import Html.Keyed
import Messages
    exposing
        ( Msg(SendAdhocMsg)
        , SendAdhocMsg
            ( ToggleSelectedContact
            , PostForm
            , UpdateAdhocFilter
            , UpdateContent
            )
        )
import Models
    exposing
        ( Model
        , Settings
        , LoadingStatus
            ( NoRequestSent
            , WaitingForPage
            , WaitingForFirstResp
            , WaitingOnRefresh
            , FinalPageReceived
            , RespFailed
            )
        )
import Models.Apostello exposing (Recipient)
import Models.SendAdhocForm exposing (SendAdhocModel)
import Pages exposing (Page(FabOnlyPage), FabOnlyPage(NewContact))
import Route exposing (page2loc)
import View.Helpers exposing (formClass, onClick)
import View.CommonSend exposing (sendButton, fieldMessage, errorFieldClass, timeField, contentField)
import View.FilteringTable exposing (filterRecord)


-- Form


view : LoadingStatus -> Settings -> SendAdhocModel -> List Recipient -> Html Msg
view ls settings model contacts =
    div []
        [ br [] []
        , case ls of
            FinalPageReceived ->
                if List.length contacts == 0 then
                    noContacts
                else
                    sendForm ls settings model contacts

            _ ->
                sendForm ls settings model contacts
        ]


noContacts : Html Msg
noContacts =
    div [ class "ui raised segment" ]
        [ p [] [ text "Looks like you don't have any contacts yet." ]
        , a [ href <| page2loc <| FabOnlyPage NewContact, class "ui violet button" ] [ text "Add a New Contact" ]
        ]


sendForm : LoadingStatus -> Settings -> SendAdhocModel -> List Recipient -> Html Msg
sendForm ls settings model contacts =
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , Html.form
            [ class <| formClass model.status, onSubmit <| SendAdhocMsg PostForm ]
            (List.map fieldMessage model.errors.all
                ++ [ contentField settings.smsCharLimit model.errors.content (SendAdhocMsg << UpdateContent) model.content
                   , contactsField ls model contacts
                   , timeField model.errors.scheduled_time model.date
                   , sendButton (SendAdhocMsg PostForm) model.cost
                   ]
            )
        ]



-- Contacts Dropdown


loadingMessage : LoadingStatus -> Html Msg
loadingMessage ls =
    case ls of
        NoRequestSent ->
            text ""

        FinalPageReceived ->
            text ""

        RespFailed err ->
            div [ class "ui secondary segment" ] [ text err ]

        WaitingForFirstResp ->
            div [ class "ui secondary segment" ] [ text "We are fetching your contactsnow..." ]

        WaitingForPage ->
            div [ class "ui secondary segment" ] [ text "We are fetching your contacts now..." ]

        WaitingOnRefresh ->
            text ""


contactsField : LoadingStatus -> SendAdhocModel -> List Recipient -> Html Msg
contactsField ls model contacts =
    div
        [ class (errorFieldClass "required field" model.errors.recipients)
        ]
        ([ label [ for "id_recipients" ] [ text "Recipients" ]
         , div [ class "ui raised segment" ]
            [ loadingMessage ls
            , div [ class "ui left icon large transparent fluid input" ]
                [ input
                    [ placeholder "Filter..."
                    , type_ "text"
                    , onInput (SendAdhocMsg << UpdateAdhocFilter)
                    ]
                    []
                , i [ class "violet filter icon" ] []
                ]
            , div
                [ class "ui divided selection list"
                , style
                    [ ( "min-height", "25vh" )
                    , ( "max-height", "50vh" )
                    , ( "overflow-y", "auto" )
                    ]
                ]
                (contacts
                    |> List.filter (filterRecord model.adhocFilter)
                    |> List.map (contactItem model.selectedContacts)
                )
            ]
         ]
            ++ List.map fieldMessage model.errors.recipients
        )


contactItem : List Int -> Recipient -> Html Msg
contactItem selectedPks contact =
    Html.Keyed.node "div"
        [ class "item", onClick <| SendAdhocMsg <| ToggleSelectedContact contact.pk ]
        [ ( toString contact.pk, contactItemHelper selectedPks contact ) ]


contactItemHelper : List Int -> Recipient -> Html Msg
contactItemHelper selectedPks contact =
    div [ class "content", style [ ( "color", "#000" ) ] ]
        [ selectedIcon selectedPks contact
        , text contact.full_name
        ]


selectedIcon : List Int -> Recipient -> Html Msg
selectedIcon selectedPks contact =
    case List.member contact.pk selectedPks of
        False ->
            text ""

        True ->
            i [ class "check icon", style [ ( "color", "#603cba" ) ] ] []
