module Models.GroupMemberSelect exposing (..)

import Regex


-- TODO use Maybe Int for pk


type alias GroupMemberSelectModel =
    { pk : Int
    , membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    }


initialGroupMemberSelectModel : GroupMemberSelectModel
initialGroupMemberSelectModel =
    { pk = 0
    , membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    }
