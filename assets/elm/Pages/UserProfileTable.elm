module Pages.UserProfileTable exposing (view)

import Css
import Data exposing (UserProfile)
import FilteringTable as FT
import Html exposing (Html)
import Html.Attributes as A
import Html.Events exposing (onClick)
import RemoteList as RL


-- Main view


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , tableModel : FT.Model
    , profiles : RL.RemoteList UserProfile
    , userProfileLink : UserProfile -> Html msg
    , toggleField : UserProfile -> msg
    }


view : Props msg -> Html msg
view props =
    FT.table { top = props.tableMsg } [] tableHead props.tableModel (userprofileRow props) props.profiles


tableHead : FT.Head
tableHead =
    FT.Head
        [ "User"
        , "Approved"
        , "Keywords"
        , "Send SMS"
        , "Contacts"
        , "Groups"
        , "Incoming"
        , "Outgoing"
        , "Archiving"
        ]


userprofileRow : Props msg -> UserProfile -> FT.Row msg
userprofileRow props userprofile =
    let
        toggleCell_ =
            toggleCell props
    in
    FT.Row
        []
        [ FT.Cell [] [ props.userProfileLink userprofile ]
        , toggleCell_ userprofile Approved
        , toggleCell_ userprofile Keywords
        , toggleCell_ userprofile SendSMS
        , toggleCell_ userprofile Contacts
        , toggleCell_ userprofile Groups
        , toggleCell_ userprofile Incoming
        , toggleCell_ userprofile Outgoing
        , toggleCell_ userprofile Archiving
        ]
        (toString userprofile.pk)


toggleCell : Props msg -> UserProfile -> Field -> FT.Cell msg
toggleCell props userprofile field =
    let
        fieldVal =
            lookupField field userprofile

        iconType =
            case fieldVal of
                True ->
                    " ✔ "

                False ->
                    " ✖ "
    in
    FT.Cell
        []
        [ Html.button
            [ onClick (props.toggleField (toggleField field userprofile))
            , A.attribute "data-test-id" (toggleDataAttr field userprofile)
            , Css.btn
            , if fieldVal then
                Css.btn_green
              else
                Css.btn_red
            ]
            [ Html.text iconType ]
        ]


toggleDataAttr : Field -> UserProfile -> String
toggleDataAttr fieldName profile =
    (toString fieldName |> String.toLower) ++ "-" ++ toString profile.pk


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
