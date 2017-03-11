module View.SendGroup exposing (view)

import Html exposing (Html, div, br, text, i, p, input, h3, button, label, a)
import Html.Attributes exposing (class, style, type_, placeholder, value, readonly, name, id, for, href)
import Html.Events exposing (onInput, onSubmit, onFocus)
import Html.Keyed
import Messages exposing (Msg(SendGroupMsg), SendGroupMsg(..))
import Models exposing (Model, Settings, LoadingStatus(..))
import Models.Apostello exposing (RecipientGroup, nullGroup)
import Models.SendGroupForm exposing (SendGroupModel)
import Pages exposing (Page(FabOnlyPage), FabOnlyPage(NewGroup))
import Route exposing (page2loc)
import View.CommonSend exposing (errorFieldClass, fieldMessage, sendButton, timeField, contentField)
import View.FilteringTable exposing (filterRecord)
import View.Helpers exposing (onClick, formClass)


-- Form


view : LoadingStatus -> Settings -> SendGroupModel -> List RecipientGroup -> Html Msg
view ls settings model groups =
    div []
        [ br [] []
        , case ls of
            FinalPageReceived ->
                if List.length groups == 0 then
                    noGroups
                else
                    modalOrForm ls settings model groups

            RespFailed _ ->
                if List.length groups == 0 then
                    noGroups
                else
                    modalOrForm ls settings model groups

            _ ->
                modalOrForm ls settings model groups
        ]


modalOrForm : LoadingStatus -> Settings -> SendGroupModel -> List RecipientGroup -> Html Msg
modalOrForm ls settings model groups =
    case model.modalOpen of
        False ->
            sendForm settings model groups

        True ->
            groupSelectModal ls model groups


noGroups : Html Msg
noGroups =
    div [ class "ui raised segment" ]
        [ p [] [ text "Looks like you don't have any (non-empty) groups yet." ]
        , a [ href <| page2loc <| FabOnlyPage NewGroup, class "ui violet button" ] [ text "Create a New Group" ]
        ]


sendForm : Settings -> SendGroupModel -> List RecipientGroup -> Html Msg
sendForm settings model groups =
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , Html.form [ class <| formClass model.status, onSubmit <| SendGroupMsg <| PostSGForm ]
            (List.map fieldMessage model.errors.all
                ++ [ contentField settings.smsCharLimit model.errors.content (SendGroupMsg << UpdateSGContent) model.content
                   , groupField model.errors.group model.selectedPk groups
                   , timeField model.errors.scheduled_time model.date
                   , sendButton (SendGroupMsg PostSGForm) model.cost
                   ]
            )
        ]


groupField : List String -> Maybe Int -> List RecipientGroup -> Html Msg
groupField errors selectedPk groups =
    div
        [ class (errorFieldClass "required field" errors)
        ]
        (List.append
            [ label [ for "id_recipient_group" ] [ text "Recipient group" ]
            , input
                [ class "ui field"
                , id "id_recipient_group"
                , name "recipient_group"
                , readonly True
                , onClick <| SendGroupMsg <| ToggleSelectGroupModal True
                , onFocus <| SendGroupMsg <| ToggleSelectGroupModal True
                , value <| selectedGroup selectedPk groups
                ]
                []
            ]
            (List.map fieldMessage errors)
        )


groupSelectModal : LoadingStatus -> SendGroupModel -> List RecipientGroup -> Html Msg
groupSelectModal ls model groups =
    div
        []
        [ button [ class "ui attached green button", onClick <| SendGroupMsg <| ToggleSelectGroupModal False ] [ text "Done" ]
        , div
            [ class "ui raised segment"
            , style [ ( "min-height", "50vh" ) ]
            ]
            [ loadingMessage ls
            , h3 [ class "ui header" ] [ text "Select a Group" ]
            , div [ class "ui left icon large transparent fluid input" ]
                [ input
                    [ placeholder "Filter..."
                    , type_ "text"
                    , onInput (SendGroupMsg << UpdateGroupFilter)
                    ]
                    []
                , i [ class "violet filter icon" ] []
                ]
            , div [ class "ui divided selection list" ]
                (groups
                    |> List.filter (filterRecord model.groupFilter)
                    |> List.map (groupItem model.selectedPk)
                )
            ]
        , div [ class "ui secondary bottom attached segment" ] [ p [] [ text "Note that empty groups are not shown here." ] ]
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
            div [ class "ui secondary segment" ] [ text "We are fetching your groups now..." ]

        WaitingForPage ->
            div [ class "ui secondary segment" ] [ text "We are fetching your groups now..." ]

        WaitingOnRefresh ->
            text ""


selectedGroup : Maybe Int -> List RecipientGroup -> String
selectedGroup selectedPk groups =
    case selectedPk of
        Nothing ->
            ""

        Just pk ->
            List.filter (\x -> x.pk == pk) groups
                |> List.head
                |> Maybe.withDefault nullGroup
                |> .name


groupItem : Maybe Int -> RecipientGroup -> Html Msg
groupItem selectedPk group =
    Html.Keyed.node "div"
        [ class "item", onClick <| SendGroupMsg <| SelectGroup group.pk ]
        [ ( toString group.pk, groupItemHelper selectedPk group ) ]


groupItemHelper : Maybe Int -> RecipientGroup -> Html Msg
groupItemHelper selectedPk group =
    div [ style [ ( "color", "#000" ) ] ]
        [ div [ class "right floated content" ] [ text <| "($" ++ toString group.cost ++ ")" ]
        , div [ class "content" ]
            [ selectedIcon selectedPk group
            , text <| group.name ++ " - " ++ group.description
            ]
        ]


selectedIcon : Maybe Int -> RecipientGroup -> Html Msg
selectedIcon selectedPk group =
    case selectedPk of
        Nothing ->
            text ""

        Just pk ->
            case pk == group.pk of
                True ->
                    i
                        [ class "check icon"
                        , style [ ( "color", "#603cba" ) ]
                        ]
                        []

                False ->
                    text ""
