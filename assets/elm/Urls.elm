module Urls exposing (..)

import Formatting exposing (..)


recipientUrl : Int -> String
recipientUrl pk =
    print (s "/api/v1/recipients/" <> int) pk


keywordUrl : Int -> String
keywordUrl pk =
    print (s "/api/v1/keywords/" <> int) pk


smsInboundUrl : Int -> String
smsInboundUrl pk =
    print (s "/api/v1/sms/in/" <> int) pk


groupsUrl_quick : Int -> String
groupsUrl_quick pk =
    print (s "/api/v1/groups/" <> int <> s "?fields!members,nonmembers") pk


elvantoGroupUrl : Int -> String
elvantoGroupUrl pk =
    print (s "/api/v1/elvanto/group/" <> int) pk


userprofileUrl : Int -> String
userprofileUrl pk =
    print (s "/api/v1/users/profiles/" <> int) pk


queuedSmsUrl : Int -> String
queuedSmsUrl pk =
    print (s "/api/v1/queued/sms/" <> int) pk
