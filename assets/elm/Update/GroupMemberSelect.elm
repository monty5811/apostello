module Update.GroupMemberSelect exposing (update)

import DjangoSend exposing (post)
import Helpers exposing (..)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (Model, DataStore, CSRFToken)
import Models.Apostello exposing (RecipientGroup, RecipientSimple, decodeRecipientGroup)
import Models.GroupMemberSelect exposing (GroupMemberSelectModel)
import View.FilteringTable as FT
import Urls
import Update.DataStore exposing (updateGroups)


update : GroupMemberSelectMsg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        UpdateMemberFilter text ->
            ( { model | groupSelect = updateMemberFilter model.groupSelect text }, [] )

        UpdateNonMemberFilter text ->
            ( { model | groupSelect = updateNonMemberFilter model.groupSelect text }, [] )

        ToggleMembership group contact ->
            ( { model | dataStore = optToggleMember group model.dataStore contact }
            , [ toggleGroupMembership
                    model.settings.csrftoken
                    group.pk
                    contact.pk
                    (memberInList group.members contact)
              ]
            )

        ReceiveToggleMembership (Ok group) ->
            ( { model | dataStore = updateGroups model.dataStore [ group ] }, [] )

        ReceiveToggleMembership (Err _) ->
            handleNotSaved model


updateMemberFilter : GroupMemberSelectModel -> String -> GroupMemberSelectModel
updateMemberFilter model text =
    { model | membersFilterRegex = FT.textToRegex text }


updateNonMemberFilter : GroupMemberSelectModel -> String -> GroupMemberSelectModel
updateNonMemberFilter model text =
    { model | nonmembersFilterRegex = FT.textToRegex text }


optToggleMember : RecipientGroup -> DataStore -> RecipientSimple -> DataStore
optToggleMember group ds contact =
    let
        updatedGroup =
            { group
                | members = optUpdateMembers group.members contact
                , nonmembers = optUpdateMembers group.nonmembers contact
            }
    in
        updateGroups ds [ updatedGroup ]


optUpdateMembers : List RecipientSimple -> RecipientSimple -> List RecipientSimple
optUpdateMembers existingList contact =
    case memberInList existingList contact of
        True ->
            existingList
                |> List.filter (\x -> not (x.pk == contact.pk))

        False ->
            contact :: existingList


memberInList : List RecipientSimple -> RecipientSimple -> Bool
memberInList existingList contact =
    List.map (\x -> x.pk) existingList
        |> List.member contact.pk


toggleGroupMembership : CSRFToken -> Int -> Int -> Bool -> Cmd Msg
toggleGroupMembership csrftoken groupPk contactPk isMember =
    let
        body =
            [ ( "member", Encode.bool isMember )
            , ( "contactPk", Encode.int contactPk )
            ]

        url =
            Urls.group groupPk
    in
        post csrftoken url body decodeRecipientGroup
            |> Http.send (GroupMemberSelectMsg << ReceiveToggleMembership)
