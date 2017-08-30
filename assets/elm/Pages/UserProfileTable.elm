module Pages.UserProfileTable exposing (view)

import Data exposing (UserProfile)
import FilteringTable as FT
import Html exposing (Html, a, button, i, td, text, th, thead, tr)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Messages exposing (Msg)
import Pages as P
import Pages.Forms.UserProfile.Model exposing (initialUserProfileFormModel)
import RemoteList as RL
import Route exposing (spaLink)
import Store.Messages exposing (StoreMsg(ToggleProfileField))


-- Main view


view : FT.Model -> RL.RemoteList UserProfile -> Html Msg
view tableModel profiles =
    FT.filteringTable "table-bordered" tableHead tableModel userprofileRow profiles


tableHead : Html Msg
tableHead =
    thead [ class "text-left" ]
        [ tr []
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
    tr [ class "text-center" ]
        [ td []
            [ spaLink a
                []
                [ text userprofile.user.email ]
                (P.UserProfileForm initialUserProfileFormModel userprofile.user.pk)
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
                    "button-success"

                False ->
                    "button-danger"

        className =
            "button button-sm " ++ buttonType

        iconType =
            case fieldVal of
                True ->
                    " ✔ "

                False ->
                    " ✖ "
    in
    td []
        [ button
            [ class className
            , onClick (Messages.StoreMsg (ToggleProfileField (toggleField field userprofile)))
            ]
            [ text iconType ]
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
