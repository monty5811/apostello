module ApostelloModels exposing (..)


type alias GroupPk =
    Int


type alias PersonPk =
    Int


type alias Group =
    { pk : GroupPk
    , name : String
    , members : List Person
    }


type alias Person =
    { full_name : String
    , pk : PersonPk
    }


type alias People =
    List Person


type alias Groups =
    List Group


nullGroup : Group
nullGroup =
    Group 0 "" []


groupsUrl : String
groupsUrl =
    "/api/v1/groups/"
