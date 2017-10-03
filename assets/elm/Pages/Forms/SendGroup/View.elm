module Pages.Forms.SendGroup.View exposing (view)

import Data exposing (RecipientGroup)
import Date
import DateTimePicker
import FilteringTable exposing (filterInput, filterRecord)
import Forms.Model exposing (Field, FieldMeta, FormItem(FormField), FormStatus)
import Forms.View exposing (contentField, form, sendButton, timeField)
import Helpers exposing (onClick)
import Html exposing (Html, a, div, i, label, p, text)
import Html.Attributes as A exposing (class, for, style)
import Html.Keyed
import Messages exposing (FormMsg(PostForm, SendGroupMsg), Msg(FormMsg))
import Models exposing (Model, Settings)
import Pages exposing (Page(GroupForm))
import Pages.Forms.Group.Model exposing (initialGroupFormModel)
import Pages.Forms.SendGroup.Messages exposing (SendGroupMsg(..))
import Pages.Forms.SendGroup.Meta exposing (meta)
import Pages.Forms.SendGroup.Model exposing (SendGroupModel)
import Pages.Forms.SendGroup.Remote exposing (postCmd)
import RemoteList as RL
import Rocket exposing ((=>))
import Route exposing (spaLink)


-- Form


view : Settings -> SendGroupModel -> RL.RemoteList RecipientGroup -> FormStatus -> Html Msg
view settings model groups status =
    div []
        [ case groups of
            RL.FinalPageReceived groups_ ->
                if List.length groups_ == 0 then
                    noGroups
                else
                    sendForm settings model groups status

            _ ->
                sendForm settings model groups status
        ]


noGroups : Html Msg
noGroups =
    div [ class "segment" ]
        [ p [] [ text "Looks like you don't have any (non-empty) groups yet." ]
        , spaLink a [ class "button" ] [ text "Create a New Group" ] <| GroupForm initialGroupFormModel Nothing
        ]


sendForm : Settings -> SendGroupModel -> RL.RemoteList RecipientGroup -> FormStatus -> Html Msg
sendForm settings model groups status =
    let
        fields =
            [ Field meta.content <| contentField meta.content settings.smsCharLimit (FormMsg << SendGroupMsg << UpdateSGContent) model.content
            , Field meta.recipient_group <| groupField meta.recipient_group model groups
            , Field meta.scheduled_time <| timeField updateSGDate meta.scheduled_time model.datePickerState model.date
            ]
                |> List.map FormField
    in
    div []
        [ p [] [ text "Send a message to a single person or to an ad-hoc group of people:" ]
        , form status fields (FormMsg <| PostForm <| postCmd settings.csrftoken settings.userPerms model) (sendButton model.cost)
        ]


updateSGDate : DateTimePicker.State -> Maybe Date.Date -> Msg
updateSGDate state maybeDate =
    FormMsg <| SendGroupMsg <| UpdateSGDate state maybeDate


groupField : FieldMeta -> SendGroupModel -> RL.RemoteList RecipientGroup -> List (Html Msg)
groupField meta_ model groups =
    [ label [ for meta_.id ] [ text meta_.label ]
    , div [ class "segment" ]
        [ loadingMessage groups
        , filterInput (FormMsg << SendGroupMsg << UpdateGroupFilter)
        , div
            [ class "list"
            , style
                [ "min-height" => "25vh"
                , "max-height" => "50vh"
                , "overflow-y" => "auto"
                ]
            ]
            (groups
                |> RL.toList
                |> List.filter (filterRecord model.groupFilter)
                |> List.map (groupItem model.selectedPk)
            )
        ]
    , div [ class "help" ] [ p [] [ text "Note that empty groups are not shown here." ] ]
    ]


loadingMessage : RL.RemoteList a -> Html Msg
loadingMessage rl =
    case rl of
        RL.NotAsked _ ->
            text ""

        RL.FinalPageReceived _ ->
            text ""

        RL.RespFailed err _ ->
            div [ class "alert" ] [ text err ]

        RL.WaitingForFirstResp _ ->
            div [ class "alert" ] [ text "We are fetching your groups now..." ]

        RL.WaitingForPage _ ->
            div [ class "alert" ] [ text "We are fetching your groups now..." ]

        RL.WaitingOnRefresh _ ->
            text ""


groupItem : Maybe Int -> RecipientGroup -> Html Msg
groupItem selectedPk group =
    Html.Keyed.node "div"
        [ class "item", onClick <| FormMsg <| SendGroupMsg <| SelectGroup group.pk, A.id "groupItem" ]
        [ ( toString group.pk, groupItemHelper selectedPk group ) ]


groupItemHelper : Maybe Int -> RecipientGroup -> Html Msg
groupItemHelper selectedPk group =
    div [ style [ "color" => "#000" ] ]
        [ Html.span [ class "float-right" ] [ text <| "($" ++ toString group.cost ++ ")" ]
        , Html.span []
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
                        [ class "fa fa-check"
                        , style [ "color" => "var(--color-purple)" ]
                        ]
                        []

                False ->
                    text ""
