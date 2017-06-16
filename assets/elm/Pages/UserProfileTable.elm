module Pages.UserProfileTable exposing (view)

import Data.User exposing (UserProfile)
import FilteringTable.Model as FTM
import FilteringTable.View exposing (filteringTable)
import Formatting as F exposing ((<>))
import Html exposing (Html, a, button, i, td, text, th, thead, tr)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Messages exposing (Msg)
import Store.Messages exposing (StoreMsg(ToggleProfileField))
import Store.RemoteList as RL


-- Main view


view : FTM.Model -> RL.RemoteList UserProfile -> Html Msg
view tableModel profiles =
    filteringTable "ui collapsing celled very basic table" tableHead tableModel userprofileRow profiles


tableHead : Html Msg
tableHead =
    thead []
        [ tr [ class "left aligned" ]
            [ th [] [ text "User" ]
            , th [] [ text "Approved" ]
            , th [] [ text "Keywords" ]
            , th [] [ text "Send SMS" ]
            , th [] [ text "Contacts" ]
            , th [] [ text "Groups" ]
            , th [] [ text "Incoming" ]
            , th [] [ text "Outgoing" ]
            , th [] [ text "Archiving" ]
            ]
        ]


userprofileRow : UserProfile -> Html Msg
userprofileRow userprofile =
    tr [ class "center aligned" ]
        [ td []
            [ a
                [ href (F.print (F.s "/users/profiles/" <> F.int <> F.s "/") userprofile.user.pk)
                ]
                [ text userprofile.user.email ]
            ]
        , toggleCell userprofile Approved
        , toggleCell userprofile Keywords
        , toggleCell userprofile SendSMS
        , toggleCell userprofile Contacts
        , toggleCell userprofile Groups
        , toggleCell userprofile Incoming
        , toggleCell userprofile Outgoing
        , toggleCell userprofile Archiving
        ]


toggleCell : UserProfile -> Field -> Html Msg
toggleCell userprofile field =
    let
        fieldVal =
            lookupField field userprofile

        buttonType =
            case fieldVal of
                True ->
                    "positive"

                False ->
                    "negative"

        className =
            "ui tiny " ++ buttonType ++ " icon button"

        iconType =
            case fieldVal of
                True ->
                    "checkmark icon"

                False ->
                    "minus circle icon"
    in
    td []
        [ button [ class className, onClick (Messages.StoreMsg (ToggleProfileField (toggleField field userprofile))) ]
            [ i [ class iconType ] []
            ]
        ]


lookupField : Field -> UserProfile -> Bool
lookupField fieldName profile =
    case fieldName of
        Approved ->
            profile.approved

        Keywords ->
            profile.can_see_keywords

        SendSMS ->
            profile.can_send_sms

        Contacts ->
            profile.can_see_contact_names

        Groups ->
            profile.can_see_groups

        Incoming ->
            profile.can_see_incoming

        Outgoing ->
            profile.can_see_outgoing

        Archiving ->
            profile.can_archive


toggleField : Field -> UserProfile -> UserProfile
toggleField field profile =
    case field of
        Approved ->
            { profile | approved = not profile.approved }

        Keywords ->
            { profile | can_see_keywords = not profile.can_see_keywords }

        SendSMS ->
            { profile | can_send_sms = not profile.can_send_sms }

        Contacts ->
            { profile | can_see_contact_names = not profile.can_see_contact_names }

        Groups ->
            { profile | can_see_groups = not profile.can_see_groups }

        Incoming ->
            { profile | can_see_incoming = not profile.can_see_incoming }

        Outgoing ->
            { profile | can_see_outgoing = not profile.can_see_outgoing }

        Archiving ->
            { profile | can_archive = not profile.can_archive }


type Field
    = Approved
    | Keywords
    | SendSMS
    | Contacts
    | Groups
    | Incoming
    | Outgoing
    | Archiving
