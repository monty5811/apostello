module Route exposing (loc2Page, page2loc, route, spaLink)

import Data exposing (UserProfile)
import Future.String
import Html exposing (Attribute, Html)
import Html.Attributes exposing (href)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Messages
    exposing
        ( Msg
            ( ContactFormMsg
            , DefaultResponsesFormMsg
            , GroupFormMsg
            , KeywordFormMsg
            , NewUrl
            , SendAdhocMsg
            , SendGroupMsg
            , SiteConfigFormMsg
            , UserProfileFormMsg
            )
        )
import Models exposing (Settings)
import Navigation
import Pages exposing (Page(..), initSendAdhoc, initSendGroup)
import Pages.Curator as C
import Pages.Debug as DG
import Pages.DeletePanel as DP
import Pages.ElvantoImport as EI
import Pages.FirstRun as FR
import Pages.Forms.Contact as CF
import Pages.Forms.ContactImport as CI
import Pages.Forms.CreateAllGroup as CAGF
import Pages.Forms.DefaultResponses as DRF
import Pages.Forms.Group as GF
import Pages.Forms.Keyword as KF
import Pages.Forms.SendAdhoc as SAF
import Pages.Forms.SendGroup as SGF
import Pages.Forms.SiteConfig as SCF
import Pages.Forms.UserProfile as UPF
import Pages.GroupComposer as GC
import Pages.GroupTable as GT
import Pages.InboundTable as IT
import Pages.KeyRespTable as KRT
import Pages.KeywordTable as KT
import Pages.OutboundTable as OT
import Pages.RecipientTable as RT
import Pages.ScheduledSmsTable as SST
import Pages.UserProfileTable as UPT
import Process
import Task
import Time
import UrlParser as Url exposing ((</>), (<?>), customParam, int, intParam, s, string, stringParam, top)


route : Url.Parser (Page -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map initSendAdhoc (s "send" </> s "adhoc" <?> stringParam "content" <?> intListParam "recipients")
        , Url.map initSendGroup (s "send" </> s "group" <?> stringParam "content" <?> intParam "recipient_group")
        , Url.map (InboundTable IT.initialModel) (s "incoming")
        , Url.map (Curator C.initialModel) (s "incoming" </> s "curate_wall")
        , Url.map (GroupTable GT.initialModel False) (s "group" </> s "all")
        , Url.map (GroupTable GT.initialModel True) (s "group" </> s "archive")
        , Url.map (GroupComposer GC.initialModel) (s "group" </> s "composer")
        , Url.map (RecipientTable RT.initialModel False) (s "recipient" </> s "all")
        , Url.map (RecipientTable RT.initialModel True) (s "recipient" </> s "archive")
        , Url.map (KeywordTable KT.initialModel False) (s "keyword" </> s "all")
        , Url.map (KeywordTable KT.initialModel True) (s "keyword" </> s "archive")
        , Url.map (KeyRespTable KRT.initialModel False) (s "keyword" </> s "responses" </> string)
        , Url.map (KeyRespTable KRT.initialModel True) (s "keyword" </> s "responses" </> s "archive" </> string)
        , Url.map (OutboundTable OT.initialModel) (s "outgoing")
        , Url.map (ScheduledSmsTable SST.initialModel) (s "scheduled" </> s "sms")
        , Url.map (UserProfileTable UPT.initialModel) (s "users" </> s "profiles")
        , Url.map (ElvantoImport EI.initialModel) (s "elvanto" </> s "import")
        , Url.map (FirstRun FR.initialModel) (s "config" </> s "first_run")
        , Url.map (Debug DG.initialModel) (s "config" </> s "debug")
        , Url.map (GroupForm << GF.initialModel << Just) (s "group" </> s "edit" </> int)
        , Url.map (GroupForm <| GF.initialModel Nothing) (s "group" </> s "new")
        , Url.map (ContactForm << CF.initialModel << Just) (s "recipient" </> s "edit" </> int)
        , Url.map (ContactForm <| CF.initialModel Nothing) (s "recipient" </> s "new")
        , Url.map (KeywordForm <| KF.initialModel Nothing) (s "keyword" </> s "new")
        , Url.map (KeywordForm << KF.initialModel << Just) (s "keyword" </> s "edit" </> string)
        , Url.map (SiteConfigForm SCF.initialModel) (s "config" </> s "site")
        , Url.map (DefaultResponsesForm DRF.initialModel) (s "config" </> s "responses")
        , Url.map (CreateAllGroup CAGF.initialModel) (s "group" </> s "create_all")
        , Url.map (UserProfileForm << UPF.initialModel) (s "users" </> s "profiles" </> int)
        , Url.map (ContactImport CI.initialModel) (s "recipient" </> s "import")
        , Url.map (ApiSetup Nothing) (s "api-setup")
        , Url.map (DeletePanel DP.initialModel) (s "config" </> s "twilio" </> s "delete")
        , Url.map Help (s "help")

        -- No Shell views:
        , Url.map Wall (s "incoming" </> s "wall")
        , Url.map Usage (s "usage")
        ]


intListParam : String -> Url.QueryParser (Maybe (List Int) -> a) a
intListParam name =
    customParam name parseListInts


parseListInts : Maybe String -> Maybe (List Int)
parseListInts str =
    Maybe.andThen parseListIntsHelp str


parseListIntsHelp : String -> Maybe (List Int)
parseListIntsHelp value =
    if String.startsWith "[" value && String.endsWith "]" value then
        value
            |> String.dropLeft 1
            |> String.dropRight 1
            |> String.split ","
            |> List.map String.toInt
            |> List.foldr (Result.map2 (::)) (Ok [])
            |> Result.toMaybe
    else
        Nothing


loc2Page : Navigation.Location -> Settings -> ( Page, Cmd Msg )
loc2Page location settings =
    Url.parsePath route location
        |> Maybe.withDefault Error404
        |> withEffects
        |> checkPagePerms settings


withEffects : Page -> ( Page, Cmd Msg )
withEffects page =
    case page of
        SendAdhoc model ->
            ( page, Cmd.map SendAdhocMsg (SAF.init model) )

        SendGroup model ->
            ( page, Cmd.map SendGroupMsg (SGF.init model) )

        KeywordForm model ->
            ( page, Cmd.map KeywordFormMsg (KF.init model) )

        ContactForm model ->
            ( page, Cmd.map ContactFormMsg (CF.init model) )

        GroupForm model ->
            ( page, Cmd.map GroupFormMsg (GF.init model) )

        SiteConfigForm _ ->
            ( page, Cmd.map SiteConfigFormMsg SCF.init )

        DefaultResponsesForm _ ->
            ( page, Cmd.map DefaultResponsesFormMsg DRF.init )

        UserProfileForm model ->
            ( page, Cmd.map UserProfileFormMsg (UPF.init model.pk) )

        _ ->
            ( page, Cmd.none )


spaLink : (List (Attribute Msg) -> List (Html Msg) -> Html Msg) -> List (Attribute Msg) -> List (Html Msg) -> Page -> Html Msg
spaLink node attrs nodes page =
    let
        uri =
            page2loc page
    in
    node (List.append [ href uri, spaLinkClick <| NewUrl uri ] attrs) nodes


spaLinkClick : msg -> Attribute msg
spaLinkClick message =
    onWithOptions "click" { stopPropagation = True, preventDefault = True } <|
        Decode.andThen (maybePreventDefault message) <|
            Decode.map3
                (\x y z -> not <| x || y || z)
                (Decode.field "ctrlKey" Decode.bool)
                (Decode.field "metaKey" Decode.bool)
                (Decode.field "shiftKey" Decode.bool)


maybePreventDefault : msg -> Bool -> Decode.Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Decode.succeed msg

        False ->
            Decode.fail "Normal link"


page2loc : Page -> String
page2loc page =
    case page of
        Home ->
            "/"

        OutboundTable _ ->
            "/outgoing/"

        InboundTable _ ->
            "/incoming/"

        GroupTable _ True ->
            "/group/archive/"

        GroupTable _ False ->
            "/group/all/"

        GroupComposer _ ->
            "/group/composer/"

        RecipientTable _ True ->
            "/recipient/archive/"

        RecipientTable _ False ->
            "/recipient/all/"

        KeywordTable _ True ->
            "/keyword/archive/"

        KeywordTable _ False ->
            "/keyword/all/"

        ElvantoImport _ ->
            "/elvanto/import/"

        Wall ->
            "/incoming/wall/"

        Curator _ ->
            "/incoming/curate_wall/"

        UserProfileTable _ ->
            "/users/profiles/"

        ScheduledSmsTable _ ->
            "/scheduled/sms/"

        KeyRespTable _ True keyword ->
            "/keyword/responses/archive/" ++ keyword ++ "/"

        KeyRespTable _ False keyword ->
            "/keyword/responses/" ++ keyword ++ "/"

        FirstRun _ ->
            "/config/first_run/"

        SendAdhoc saModel ->
            addAdhocParams (SAF.getParams saModel) "/send/adhoc/"

        SendGroup sgModel ->
            addGroupParams (SGF.getParams sgModel) "/send/group/"

        GroupForm { maybePk } ->
            case maybePk of
                Nothing ->
                    "/group/new/"

                Just pk ->
                    "/group/edit/" ++ Future.String.fromInt pk ++ "/"

        ContactForm cfModel ->
            case cfModel.maybePk of
                Nothing ->
                    "/recipient/new/"

                Just pk ->
                    "/recipient/edit/" ++ Future.String.fromInt pk ++ "/"

        KeywordForm { maybeId } ->
            case maybeId of
                Nothing ->
                    "/keyword/new/"

                Just k ->
                    "/keyword/edit/" ++ k ++ "/"

        SiteConfigForm _ ->
            "/config/site/"

        DefaultResponsesForm _ ->
            "/config/responses/"

        Debug _ ->
            "/config/debug/"

        CreateAllGroup _ ->
            "/group/create_all/"

        Usage ->
            "/usage/"

        Help ->
            "/help/"

        UserProfileForm model ->
            "/users/profiles/" ++ Future.String.fromInt model.pk ++ "/"

        ContactImport _ ->
            "/recipient/import/"

        ApiSetup _ ->
            "/api-setup/"

        AccessDenied ->
            "/"

        Error404 ->
            "/"

        DeletePanel _ ->
            "/config/twilio/delete"


addAdhocParams : ( Maybe String, Maybe (List Int) ) -> String -> String
addAdhocParams ( maybeContent, maybePks ) url =
    let
        params =
            [ contentParam maybeContent, contactsParam maybePks ]
                |> List.filter notNothing
                |> List.map (Maybe.withDefault "")
                |> String.join "&"
    in
    url ++ "?" ++ params


addGroupParams : ( Maybe String, Maybe Int ) -> String -> String
addGroupParams ( maybeContent, maybePk ) url =
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
        Just _ ->
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
            "recipients=[" ++ (x |> List.map Future.String.fromInt |> String.join ",") ++ "]"
        )
        contacts


groupParam : Maybe Int -> Maybe String
groupParam g =
    Maybe.map (\x -> "recipient_group=" ++ Future.String.fromInt x) g



-- permissions check


delayedNavigate : Time.Time -> Page -> Cmd Msg
delayedNavigate t page =
    Process.sleep t
        |> Task.andThen (always <| Task.succeed (NewUrl <| page2loc page))
        |> Task.perform identity


checkPagePerms : Settings -> ( Page, Cmd Msg ) -> ( Page, Cmd Msg )
checkPagePerms settings ( page, cmd ) =
    case settings.userPerms.user.is_staff of
        True ->
            ( page, cmd )

        False ->
            checkPerm settings.blockedKeywords settings.userPerms page


checkPerm : List String -> UserProfile -> Page -> ( Page, Cmd Msg )
checkPerm blockedKeywords userPerms page =
    let
        permBool =
            case page of
                OutboundTable _ ->
                    userPerms.can_see_outgoing

                InboundTable _ ->
                    userPerms.can_see_incoming

                GroupTable _ False ->
                    userPerms.can_see_groups

                GroupTable _ True ->
                    userPerms.user.is_staff

                GroupComposer _ ->
                    userPerms.can_see_contact_names && userPerms.can_see_groups

                RecipientTable _ False ->
                    userPerms.can_see_contact_names

                RecipientTable _ True ->
                    userPerms.user.is_staff

                KeywordTable _ False ->
                    userPerms.can_see_keywords

                KeywordTable _ True ->
                    userPerms.user.is_staff

                ElvantoImport _ ->
                    userPerms.can_import

                Wall ->
                    userPerms.can_see_incoming

                Curator _ ->
                    userPerms.can_see_incoming

                UserProfileTable _ ->
                    userPerms.user.is_staff

                ScheduledSmsTable _ ->
                    userPerms.user.is_staff

                KeyRespTable _ _ k ->
                    userPerms.can_see_keywords && (List.member k blockedKeywords |> not)

                FirstRun _ ->
                    True

                AccessDenied ->
                    True

                SendAdhoc _ ->
                    userPerms.can_send_sms

                SendGroup _ ->
                    userPerms.can_send_sms

                Error404 ->
                    True

                GroupForm _ ->
                    userPerms.can_see_groups

                ContactForm _ ->
                    userPerms.can_see_contact_names

                KeywordForm { maybeId } ->
                    case maybeId of
                        Nothing ->
                            userPerms.can_see_keywords

                        Just k ->
                            userPerms.can_see_keywords && (List.member k blockedKeywords |> not)

                Home ->
                    True

                SiteConfigForm _ ->
                    userPerms.user.is_staff

                DefaultResponsesForm _ ->
                    userPerms.user.is_staff

                CreateAllGroup _ ->
                    userPerms.user.is_staff

                Usage ->
                    userPerms.user.is_staff

                Help ->
                    True

                UserProfileForm _ ->
                    userPerms.user.is_staff

                ContactImport _ ->
                    userPerms.can_import

                ApiSetup _ ->
                    userPerms.user.is_staff

                DeletePanel _ ->
                    userPerms.user.is_staff

                Debug _ ->
                    userPerms.user.is_staff
    in
    case permBool of
        True ->
            ( page, Cmd.none )

        False ->
            ( AccessDenied, delayedNavigate (3 * Time.second) Home )
