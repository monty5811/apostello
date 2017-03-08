module Route exposing (..)

import Formatting as F exposing ((<>))
import Models exposing (..)
import Navigation
import UrlParser as Url exposing ((</>), (<?>), s, int, customParam, stringParam, intParam, top, string)


loc2Page : Navigation.Location -> Settings -> Page
loc2Page location settings =
    Url.parsePath route location
        |> Maybe.withDefault Error404
        |> checkPagePerms settings


route : Url.Parser (Page -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map SendAdhoc (s "send" </> s "adhoc" <?> stringParam "content" <?> intListParam "recipients")
        , Url.map SendGroup (s "send" </> s "group" <?> stringParam "content" <?> intParam "recipient_group")
        , Url.map InboundTable (s "incoming")
        , Url.map Curator (s "incoming" </> s "curate_wall")
        , Url.map (GroupTable False) (s "group" </> s "all")
        , Url.map (GroupTable True) (s "group" </> s "archive")
        , Url.map GroupComposer (s "group" </> s "composer")
        , Url.map (RecipientTable False) (s "recipient" </> s "all")
        , Url.map (RecipientTable True) (s "recipient" </> s "archive")
        , Url.map (KeywordTable False) (s "keyword" </> s "all")
        , Url.map (KeywordTable True) (s "keyword" </> s "archive")
        , Url.map (KeyRespTable False) (s "keyword" </> s "responses" </> string)
        , Url.map (KeyRespTable True) (s "keyword" </> s "responses" </> s "archive" </> string)
        , Url.map OutboundTable (s "outgoing")
        , Url.map ScheduledSmsTable (s "scheduled" </> s "sms")
        , Url.map UserProfileTable (s "users" </> s "profiles")
        , Url.map ElvantoImport (s "elvanto" </> s "import")
        , Url.map FirstRun (s "config" </> s "first_run")
          -- No Shell views:
        , Url.map Wall (s "incoming" </> s "wall")
        , Url.map EditGroup (s "group" </> s "edit" </> int)
        , Url.map EditContact (s "recipient" </> s "edit" </> int)
          -- Fab only views:
        , Url.map (FabOnlyPage Help) (s "help")
        , Url.map (FabOnlyPage NewGroup) (s "group" </> s "new")
        , Url.map (FabOnlyPage CreateAllGroup) (s "group" </> s "create_all")
        , Url.map (FabOnlyPage NewContact) (s "recipient" </> s "new")
        , Url.map (FabOnlyPage NewKeyword) (s "keyword" </> s "new")
        , Url.map (FabOnlyPage << EditKeyword) (s "keyword" </> s "edit" </> string)
        , Url.map (FabOnlyPage ContactImport) (s "recipient" </> s "import")
        , Url.map (FabOnlyPage ApiSetup) (s "api-setup")
        , Url.map (FabOnlyPage << EditUserProfile) (s "users" </> s "profiles" </> int)
        , Url.map (FabOnlyPage EditSiteConfig) (s "config" </> s "site")
        , Url.map (FabOnlyPage EditResponses) (s "config" </> s "responses")
        ]


intListParam : String -> Url.QueryParser (Maybe (List Int) -> a) a
intListParam name =
    customParam name parseListInts


parseListInts : Maybe String -> Maybe (List Int)
parseListInts s =
    case s of
        Nothing ->
            Nothing

        Just value ->
            if (String.startsWith "[" value) && (String.endsWith "]" value) then
                value
                    |> String.dropLeft 1
                    |> String.dropRight 1
                    |> String.split ","
                    |> List.map String.toInt
                    |> List.foldr (Result.map2 (::)) (Ok [])
                    |> Result.toMaybe
            else
                Nothing


page2loc : Page -> String
page2loc page =
    case page of
        Home ->
            "/"

        OutboundTable ->
            "/outgoing/"

        InboundTable ->
            "/incoming/"

        GroupTable True ->
            "/group/archive/"

        GroupTable False ->
            "/group/all/"

        GroupComposer ->
            "/group/composer/"

        RecipientTable True ->
            "/recipient/archive/"

        RecipientTable False ->
            "/recipient/all/"

        KeywordTable True ->
            "/keyword/archive/"

        KeywordTable False ->
            "/keyword/all/"

        ElvantoImport ->
            "/elvanto/import/"

        Wall ->
            "/incoming/wall/"

        Curator ->
            "/incoming/curate_wall/"

        UserProfileTable ->
            "/users/profiles/"

        ScheduledSmsTable ->
            "/scheduled/sms/"

        KeyRespTable True keyword ->
            "/keyword/responses/archive/" ++ keyword ++ "/"

        KeyRespTable False keyword ->
            "/keyword/responses/" ++ keyword ++ "/"

        FirstRun ->
            "/config/first_run/"

        SendAdhoc content pks ->
            "/send/adhoc/" |> addAdhocParams content pks

        SendGroup content pk ->
            "/send/group/" |> addGroupParams content pk

        EditGroup pk ->
            F.print (F.s "/group/edit/" <> F.int <> F.s "/") pk

        EditContact pk ->
            F.print (F.s "/recipient/edit/" <> F.int <> F.s "/") pk

        FabOnlyPage f ->
            case f of
                NewKeyword ->
                    "/keyword/new/"

                NewGroup ->
                    "/group/new/"

                NewContact ->
                    "/recipient/new/"

                CreateAllGroup ->
                    "/group/create_all/"

                EditKeyword k ->
                    F.print (F.s "/keyword/edit/" <> F.string <> F.s "/") k

                EditUserProfile pk ->
                    F.print (F.s "/users/profiles/" <> F.int <> F.s "/") pk

                ContactImport ->
                    "/recipient/import/"

                ApiSetup ->
                    "/api-setup/"

                EditSiteConfig ->
                    "/config/site/"

                EditResponses ->
                    "/config/responses/"

                Help ->
                    "/help/"

        AccessDenied ->
            "/"

        Error404 ->
            "/"


addAdhocParams : Maybe String -> Maybe (List Int) -> String -> String
addAdhocParams maybeContent maybePks url =
    let
        params =
            [ contentParam maybeContent, contactsParam maybePks ]
                |> List.filter notNothing
                |> List.map (Maybe.withDefault "")
                |> String.join "&"
    in
        url ++ "?" ++ params


addGroupParams : Maybe String -> Maybe Int -> String -> String
addGroupParams maybeContent maybePk url =
    let
        params =
            [ contentParam maybeContent, groupParam maybePk ]
                |> List.filter notNothing
                |> List.map (Maybe.withDefault "")
                |> String.join "&"
    in
        url ++ "?" ++ params


notNothing : Maybe a -> Bool
notNothing m =
    case m of
        Just a ->
            True

        Nothing ->
            False


contentParam : Maybe String -> Maybe String
contentParam content =
    Maybe.map (\x -> "content=" ++ x) content


contactsParam : Maybe (List Int) -> Maybe String
contactsParam contacts =
    Maybe.map
        (\x ->
            F.print (F.s "recipients=[" <> F.string <> F.s "]") (x |> List.map toString |> String.join ",")
        )
        contacts


groupParam : Maybe Int -> Maybe String
groupParam g =
    Maybe.map (F.print (F.s "recipient_group=" <> F.int)) g



-- permissions check


checkPagePerms : Settings -> Page -> Page
checkPagePerms settings page =
    case settings.userPerms.user.is_staff of
        True ->
            page

        False ->
            checkPerm settings.blockedKeywords settings.userPerms page


checkPerm : List String -> UserProfile -> Page -> Page
checkPerm blockedKeywords userPerms page =
    let
        permBool =
            case page of
                OutboundTable ->
                    userPerms.can_see_outgoing

                InboundTable ->
                    userPerms.can_see_incoming

                GroupTable _ ->
                    userPerms.can_see_groups

                GroupComposer ->
                    userPerms.can_see_contact_names && userPerms.can_see_groups

                RecipientTable _ ->
                    userPerms.can_see_contact_names

                KeywordTable _ ->
                    userPerms.can_see_keywords

                ElvantoImport ->
                    userPerms.can_import

                Wall ->
                    userPerms.can_see_incoming

                Curator ->
                    userPerms.can_see_incoming

                UserProfileTable ->
                    userPerms.user.is_staff

                ScheduledSmsTable ->
                    userPerms.user.is_staff

                KeyRespTable _ k ->
                    userPerms.can_see_keywords && (List.member k blockedKeywords |> not)

                FirstRun ->
                    True

                AccessDenied ->
                    True

                SendAdhoc _ _ ->
                    userPerms.can_send_sms

                SendGroup _ _ ->
                    userPerms.can_send_sms

                Error404 ->
                    True

                EditGroup _ ->
                    userPerms.can_see_groups

                EditContact _ ->
                    True

                Home ->
                    True

                FabOnlyPage _ ->
                    True
    in
        case permBool of
            True ->
                page

            False ->
                AccessDenied
