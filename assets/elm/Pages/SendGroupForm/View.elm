module Pages.SendGroupForm.View exposing (view)

import Data.RecipientGroup exposing (RecipientGroup)
import Data.Store as Store
import Date
import DateTimePicker
import FilteringTable.Util exposing (filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (form)
import Forms.View.Send exposing (contentField, sendButton, timeField)
import Helpers exposing (onClick)
import Html exposing (Html, a, br, div, i, input, label, p, text)
import Html.Attributes exposing (class, for, placeholder, style, type_)
import Html.Events exposing (onInput)
import Html.Keyed
import Messages exposing (FormMsg(PostSGForm), Msg(FormMsg, SendGroupMsg))
import Models exposing (Model, Settings)
import Pages exposing (Page(GroupForm))
import Pages.GroupForm.Model exposing (initialGroupFormModel)
import Pages.SendGroupForm.Messages exposing (SendGroupMsg(..))
import Pages.SendGroupForm.Meta exposing (meta)
import Pages.SendGroupForm.Model exposing (SendGroupModel)
import Route exposing (spaLink)


-- Form


view : Settings -> SendGroupModel -> Store.RemoteList RecipientGroup -> FormStatus -> Html Msg
view settings model groups status =
    div []
        [ br [] []
        , case groups of
            Store.FinalPageReceived groups_ ->
                if List.length groups_ == 0 then
                    noGroups
                else
                    sendForm settings model groups status

            _ ->
                sendForm settings model groups status
        ]


noGroups : Html Msg
noGroups =
    div [ class "ui raised segment" ]
        [ p [] [ text "Looks like you don't have any (non-empty) groups yet." ]
        , spaLink a [ class "ui violet button" ] [ text "Create a New Group" ] <| GroupForm initialGroupFormModel Nothing
        ]


sendForm : Settings -> SendGroupModel -> Store.RemoteList RecipientGroup -> FormStatus -> Html Msg
sendForm settings model groups status =
    let
        fields =
            [ Field meta.content <| contentField meta.content settings.smsCharLimit (SendGroupMsg << UpdateSGContent) model.content
            , Field meta.recipient_group <| groupField meta.recipient_group model groups
            , Field meta.scheduled_time <| timeField updateSGDate meta.scheduled_time model.datePickerState model.date
            ]
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields (FormMsg <| PostSGForm model) (sendButton model.cost)
        ]


updateSGDate : DateTimePicker.State -> Maybe Date.Date -> Msg
updateSGDate state maybeDate =
    SendGroupMsg <| UpdateSGDate state maybeDate


groupField : FieldMeta -> SendGroupModel -> Store.RemoteList RecipientGroup -> List (Html Msg)
groupField meta model groups =
    [ label [ for meta.id ] [ text meta.label ]
    , div [ class "ui raised segment" ]
        [ loadingMessage groups
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
                |> Store.toList
                |> List.filter (filterRecord model.groupFilter)
                |> List.map (groupItem model.selectedPk)
            )
        , div [ class "ui secondary bottom attached segment" ] [ p [] [ text "Note that empty groups are not shown here." ] ]
        ]
    ]


loadingMessage : Store.RemoteList a -> Html Msg
loadingMessage rl =
    case rl of
        Store.NotAsked _ ->
            text ""

        Store.FinalPageReceived _ ->
            text ""

        Store.RespFailed err _ ->
            div [ class "ui secondary segment" ] [ text err ]

        Store.WaitingForFirstResp _ ->
            div [ class "ui secondary segment" ] [ text "We are fetching your groups now..." ]

        Store.WaitingForPage _ ->
            div [ class "ui secondary segment" ] [ text "We are fetching your groups now..." ]

        Store.WaitingOnRefresh _ ->
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
