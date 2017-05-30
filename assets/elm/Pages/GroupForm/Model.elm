module Pages.GroupForm.Model exposing (..)

import Regex


type alias GroupFormModel =
    { membersFilterRegex : Regex.Regex
    , nonmembersFilterRegex : Regex.Regex
    , name : Maybe String
    , description : Maybe String
    }


initialGroupFormModel : GroupFormModel
initialGroupFormModel =
    { membersFilterRegex = Regex.regex ""
    , nonmembersFilterRegex = Regex.regex ""
    , name = Nothing
    , description = Nothing
    }
