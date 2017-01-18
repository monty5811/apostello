module Updates.GroupMemberSelect exposing (update)

import Biu exposing (..)
import Decoders exposing (recipientgroupDecoder)
import DjangoSend exposing (post)
import Helpers exposing (encodeBody, getData)
import Http
import Json.Encode as Encode
import Messages exposing (..)
import Models exposing (..)
import Views.FilteringTable as FT


update : GroupMemberSelectMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadGroupMemberSelectResp (Ok group) ->
            ( { model
                | loadingStatus = Finished
                , groupSelect = updateGroup model.groupSelect group
              }
            , Cmd.none
            )

        LoadGroupMemberSelectResp (Err _) ->
            ( { model | loadingStatus = Finished }, biuLoadingFailed )

        UpdateMemberFilter text ->
            ( { model | groupSelect = updateMemberFilter model.groupSelect text }, Cmd.none )

        UpdateNonMemberFilter text ->
            ( { model | groupSelect = updateNonMemberFilter model.groupSelect text }, Cmd.none )

        ToggleMembership contact ->
            ( { model | groupSelect = optToggleMember model.groupSelect contact }
            , toggleGroupMembership
                model.csrftoken
                model.dataUrl
                contact.pk
                (memberInList model.groupSelect.members contact)
            )

        ReceiveToggleMembership (Ok group) ->
            ( { model
                | loadingStatus = Finished
                , groupSelect = updateGroup model.groupSelect group
              }
            , Cmd.none
            )

        ReceiveToggleMembership (Err _) ->
            ( { model | loadingStatus = Finished }, biuLoadingFailed )


updateMemberFilter : GroupMemberSelectModel -> String -> GroupMemberSelectModel
updateMemberFilter model text =
    { model | membersFilterRegex = FT.textToRegex text }


updateNonMemberFilter : GroupMemberSelectModel -> String -> GroupMemberSelectModel
updateNonMemberFilter model text =
    { model | nonmembersFilterRegex = FT.textToRegex text }


updateGroup : GroupMemberSelectModel -> RecipientGroup -> GroupMemberSelectModel
updateGroup model group =
    { model
        | pk = group.pk
        , description = group.description
        , members = group.members
        , nonmembers = group.nonmembers
        , url = group.url
    }


optToggleMember : GroupMemberSelectModel -> RecipientSimple -> GroupMemberSelectModel
optToggleMember model contact =
    { model
        | members = optUpdateMembers model.members contact
        , nonmembers = optUpdateMembers model.nonmembers contact
    }


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


toggleGroupMembership : CSRFToken -> String -> Int -> Bool -> Cmd Msg
toggleGroupMembership csrftoken url pk isMember =
    let
        body =
            encodeBody
                [ ( "member", Encode.bool isMember )
                , ( "contactPk", Encode.int pk )
                ]
    in
        post url body csrftoken recipientgroupDecoder
            |> Http.send (GroupMemberSelectMsg << ReceiveToggleMembership)
