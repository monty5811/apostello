module Actions exposing (..)

import Decoders exposing (..)
import Helpers exposing (getApostelloResponse, getData, increasePageSize, determineLoadingStatus)
import Http
import Messages exposing (..)
import Models exposing (..)


fetchData : Page -> String -> Cmd Msg
fetchData page dataUrl =
    case page of
        OutboundTable ->
            Http.send (OutboundTableMsg << LoadOutboundTableResp) (getApostelloResponse dataUrl smsoutboundDecoder)

        InboundTable ->
            Http.send (InboundTableMsg << LoadInboundTableResp) (getApostelloResponse dataUrl smsinboundDecoder)

        GroupTable ->
            Http.send (GroupTableMsg << LoadGroupTableResp) (getApostelloResponse dataUrl recipientgroupDecoder)

        GroupComposer ->
            Http.send (GroupComposerMsg << LoadGroupComposerResp) (getApostelloResponse dataUrl recipientgroupDecoder)

        GroupSelect ->
            Http.send (GroupMemberSelectMsg << LoadGroupMemberSelectResp) (getData dataUrl recipientgroupDecoder)

        RecipientTable ->
            Http.send (RecipientTableMsg << LoadRecipientTableResp) (getApostelloResponse dataUrl recipientDecoder)

        KeywordTable ->
            Http.send (KeywordTableMsg << LoadKeywordTableResp) (getApostelloResponse dataUrl keywordDecoder)

        ElvantoImport ->
            Http.send (ElvantoMsg << LoadElvantoResp) (getApostelloResponse dataUrl elvantogroupDecoder)

        Wall ->
            Http.send (WallMsg << LoadWallResp) (getApostelloResponse dataUrl smsinboundsimpleDecoder)

        Curator ->
            Http.send (WallMsg << LoadWallResp) (getApostelloResponse dataUrl smsinboundsimpleDecoder)

        UserProfileTable ->
            Http.send (UserProfileTableMsg << LoadUserProfileTableResp) (getApostelloResponse dataUrl userprofileDecoder)

        ScheduledSmsTable ->
            Http.send (ScheduledSmsTableMsg << LoadScheduledSmsTableResp) (getApostelloResponse dataUrl queuedsmsDecoder)

        KeyRespTable ->
            Http.send (KeyRespTableMsg << LoadKeyRespTableResp) (getApostelloResponse dataUrl smsinboundDecoder)

        Fab ->
            Cmd.none

        FirstRun ->
            Cmd.none


determineRespCmd : Page -> ApostelloResponse a -> Cmd Msg
determineRespCmd page resp =
    case resp.next of
        Nothing ->
            Cmd.none

        Just url ->
            fetchData page (increasePageSize url)
