module Urls
    exposing
        ( elvantoFetchGroups
        , elvantoGroup
        , elvantoGroups
        , elvantoPullGroups
        , group
        , groups
        , keyword
        , keywordArchiveResps
        , keywords
        , queuedSms
        , queuedSmss
        , recipient
        , recipients
        , sendAdhoc
        , sendGroup
        , smsInbound
        , smsInbounds
        , smsOutbounds
        , userProfiles
        , userprofile
        )

import Formatting exposing ((<>), int, s, print, string)


recipient : Int -> String
recipient pk =
    print (s "/api/v1/recipients/" <> int <> s "/") pk


recipients : String
recipients =
    "/api/v1/recipients/"


keyword : String -> String
keyword k =
    print (s "/api/v1/keywords/" <> string <> s "/") k


keywordArchiveResps : String -> String
keywordArchiveResps k =
    print (s "/api/v1/keywords/" <> string <> s "/archive_resps/") k


smsInbounds : String
smsInbounds =
    "/api/v1/sms/in/"


smsInbound : Int -> String
smsInbound pk =
    print (s "/api/v1/sms/in/" <> int <> s "/") pk


elvantoGroup : Int -> String
elvantoGroup pk =
    print (s "/api/v1/elvanto/group/" <> int <> s "/") pk


userprofile : Int -> String
userprofile pk =
    print (s "/api/v1/users/profiles/" <> int <> s "/") pk


queuedSms : Int -> String
queuedSms pk =
    print (s "/api/v1/queued/sms/" <> int <> s "/") pk


queuedSmss : String
queuedSmss =
    "/api/v1/queued/sms/"


group : Int -> String
group pk =
    print (s "/api/v1/groups/" <> int <> s "/") pk


smsOutbounds : String
smsOutbounds =
    "/api/v1/sms/out/"


groups : String
groups =
    "/api/v1/groups/"


keywords : String
keywords =
    "/api/v1/keywords/"


elvantoGroups : String
elvantoGroups =
    "/api/v1/elvanto/groups/"


userProfiles : String
userProfiles =
    "/api/v1/users/profiles/"



-- sending


sendGroup : String
sendGroup =
    "/api/v1/sms/send/group/"


sendAdhoc : String
sendAdhoc =
    "/api/v1/sms/send/adhoc/"



-- elvanto actions


elvantoPullGroups : String
elvantoPullGroups =
    "/api/v1/elvanto/group_pull/"


elvantoFetchGroups : String
elvantoFetchGroups =
    "/api/v1/elvanto/group_fetch/"
