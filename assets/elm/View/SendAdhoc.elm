module View.SendAdhoc exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Html.Keyed
import Messages exposing (Msg(SendAdhocMsg), SendAdhocMsg(..))
import Models exposing (Model, Settings, LoadingStatus(..))
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
                    modalOrForm ls settings model contacts

            RespFailed _ ->
                if List.length contacts == 0 then
                    noContacts
                else
                    modalOrForm ls settings model contacts

            _ ->
                modalOrForm ls settings model contacts
        ]


modalOrForm : LoadingStatus -> Settings -> SendAdhocModel -> List Recipient -> Html Msg
modalOrForm ls settings model contacts =
    case model.modalOpen of
        True ->
            adhocSelectModal ls model contacts

        False ->
            sendForm settings model contacts


noContacts : Html Msg
noContacts =
    div [ class "ui raised segment" ]
        [ p [] [ text "Looks like you don't have any contacts yet." ]
        , a [ href <| page2loc <| FabOnlyPage NewContact, class "ui violet button" ] [ text "Add a New Contact" ]
        ]


sendForm : Settings -> SendAdhocModel -> List Recipient -> Html Msg
sendForm settings model contacts =
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , Html.form
            [ class <| formClass model.status, onSubmit <| SendAdhocMsg PostForm ]
            (List.map fieldMessage model.errors.all
                ++ [ contentField settings.smsCharLimit model.errors.content (SendAdhocMsg << UpdateContent) model.content
                   , contactsField model contacts
                   , timeField model.errors.scheduled_time model.date
                   , sendButton (SendAdhocMsg PostForm) model.cost
                   ]
            )
        ]



-- Contacts Dropdown


adhocSelectModal : LoadingStatus -> SendAdhocModel -> List Recipient -> Html Msg
adhocSelectModal ls model contacts =
    div []
        [ button [ class "ui attached green button", onClick <| SendAdhocMsg <| ToggleSelectAdhocModal False ] [ text "Done" ]
        , div
            [ class "ui raised segment"
            , style [ ( "min-height", "50vh" ) ]
            ]
            [ loadingMessage ls
            , h3 [ class "ui header" ] [ text "Select Recipients" ]
            , div [ class "ui left icon large transparent fluid input" ]
                [ input
                    [ placeholder "Filter..."
                    , type_ "text"
                    , onInput (SendAdhocMsg << UpdateAdhocFilter)
                    ]
                    []
                , i [ class "violet filter icon" ] []
                ]
            , div [ class "ui divided selection list" ]
                (contacts
                    |> List.filter (filterRecord model.adhocFilter)
                    |> List.map (contactItem model.selectedContacts)
                )
            ]
        ]


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


contactsField : SendAdhocModel -> List Recipient -> Html Msg
contactsField model contacts =
    div
        [ class (errorFieldClass "required field" model.errors.recipients)
        ]
        ([ label [ for "id_recipients" ] [ text "Recipients" ]
         , div
            [ class "ui compact search dropdown selection multiple"
            , id "id_recipients"
            , name "recipients"
            , onClick <| SendAdhocMsg <| ToggleSelectAdhocModal True
            ]
            (input
                [ style [ ( "width", "100% !important" ) ]
                , id "recipients_input"
                , readonly True
                ]
                [ text "" ]
                :: selectedItems contacts model.selectedContacts
            )
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


selectedItems : List Recipient -> List Int -> List (Html Msg)
selectedItems contacts pks =
    contacts
        |> List.filter (\x -> List.member x.pk pks)
        |> List.map selectedItem


selectedItem : Recipient -> Html Msg
selectedItem contact =
    a
        [ class "ui label visible"
        , style [ ( "display", "inline-block !important" ) ]
        ]
        [ text contact.full_name ]
