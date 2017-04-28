module View.SendGroup exposing (view)

import Html exposing (Html, div, br, text, i, p, input, label, a)
import Html.Attributes exposing (class, style, type_, placeholder, for, href)
import Html.Events exposing (onInput, onSubmit)
import Html.Keyed
import Messages
    exposing
        ( Msg(SendGroupMsg)
        , SendGroupMsg(SelectGroup, UpdateGroupFilter, PostSGForm, UpdateSGContent)
        )
import Models
    exposing
        ( Model
        , Settings
        , LoadingStatus(NoRequestSent, WaitingForFirstResp, WaitingOnRefresh, WaitingForPage, RespFailed, FinalPageReceived)
        )
import Models.Apostello exposing (RecipientGroup)
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
                    sendForm ls settings model groups

            _ ->
                sendForm ls settings model groups
        ]


noGroups : Html Msg
noGroups =
    div [ class "ui raised segment" ]
        [ p [] [ text "Looks like you don't have any (non-empty) groups yet." ]
        , a [ href <| page2loc <| FabOnlyPage NewGroup, class "ui violet button" ] [ text "Create a New Group" ]
        ]


sendForm : LoadingStatus -> Settings -> SendGroupModel -> List RecipientGroup -> Html Msg
sendForm ls settings model groups =
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , Html.form [ class <| formClass model.status, onSubmit <| SendGroupMsg <| PostSGForm ]
            (List.map fieldMessage model.errors.all
                ++ [ contentField settings.smsCharLimit model.errors.content (SendGroupMsg << UpdateSGContent) model.content
                   , groupField ls model groups
                   , timeField model.errors.scheduled_time model.date
                   , sendButton (SendGroupMsg PostSGForm) model.cost
                   ]
            )
        ]


groupField : LoadingStatus -> SendGroupModel -> List RecipientGroup -> Html Msg
groupField ls model groups =
    div
        [ class (errorFieldClass "required field" model.errors.group)
        ]
        (List.append
            [ label [ for "id_recipient_group" ] [ text "Recipient group" ]
            , div [ class "ui raised segment" ]
                [ loadingMessage ls
                , div [ class "ui left icon large transparent fluid input" ]
                    [ input
                        [ placeholder "Filter..."
                        , type_ "text"
                        , onInput (SendGroupMsg << UpdateGroupFilter)
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
                    (groups
                        |> List.filter (filterRecord model.groupFilter)
                        |> List.map (groupItem model.selectedPk)
                    )
                , div [ class "ui secondary bottom attached segment" ] [ p [] [ text "Note that empty groups are not shown here." ] ]
                ]
            ]
            (List.map fieldMessage model.errors.group)
        )


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
