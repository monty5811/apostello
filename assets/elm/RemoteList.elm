module RemoteList exposing
    ( RemoteList(..)
    , toList, map, filter, apply, hasFailed, hasFinished
    )

{-| This library provides helpers for working with lists of remote data.

@docs RemoteList


# Helpers

@docs toList, map, filter, apply, hasFailed, hasFinished

-}


{-| Represent a list of remote (paged) data as one of 6 possible states:

  - `NotAsked` - We haven't asked for anything yet.
  - `WaitingForFirstResp` - We've asked, but we are waiting for the first response.
  - `WaitingForPage` - We asked for another page and are waiting.
  - `FinalPageReceived` - Everything worked, all the pages have been received.
  - `WaitingOnRefresh` - All the data has been loaded and we are waiting before refreshing.
  - `RespFailed` - Something went wrong, here is the error and the data we have so far.

-}
type RemoteList a
    = NotAsked (List a)
    | WaitingForFirstResp (List a)
    | WaitingForPage (List a)
    | FinalPageReceived (List a)
    | WaitingOnRefresh (List a)
    | RespFailed String (List a)


{-| Check if the fetching has failed.

    hasFailed (NotAsked [ 1, 2 ]) --> False

    hasFailed (RespFailed "Server did not respond" [ 1, 2 ]) --> True

-}
hasFailed : RemoteList a -> Bool
hasFailed ls =
    case ls of
        RespFailed _ _ ->
            True

        _ ->
            False


{-| Check if the fetching has finished.

    hasFinished (NotAsked [ 1, 2 ]) --> False

    hasFinished (RespFailed "Server did not respond" [ 1, 2 ]) --> False

    hasFinished (FinalPageReceived [ 1, 2 ]) --> True

-}
hasFinished : RemoteList a -> Bool
hasFinished ls =
    case ls of
        FinalPageReceived _ ->
            True

        _ ->
            False


{-| Convert a remote list into a normal list

    toList (FinalPageReceived [ 1, 2, 3 ]) --> [1, 2, 3]

-}
toList : RemoteList a -> List a
toList rl =
    case rl of
        NotAsked l ->
            l

        WaitingForFirstResp l ->
            l

        WaitingForPage l ->
            l

        FinalPageReceived l ->
            l

        WaitingOnRefresh l ->
            l

        RespFailed _ l ->
            l


{-| Apply a function to every element of the list.

    map sqrt (WaitingForPage [ 4, 9, 16 ]) --> (WaitingForPage [2, 3, 4])

-}
map : (a -> b) -> RemoteList a -> RemoteList b
map fn rl =
    apply (List.map fn) rl


{-| Keep only elements that satisfy the predicate.

    filter (\i -> i > 1) (WaitingForPage [ 1, 2, 3 ]) --> (WaitingForPage [2, 3])

-}
filter : (a -> Bool) -> RemoteList a -> RemoteList a
filter fn rl =
    apply (List.filter fn) rl


{-| Apply a function to the list.

    apply List.sort (WaitingForPage [ 3, 1, 2 ]) --> (WaitingForPage [1, 2, 3])

    apply (List.take 2 >> List.reverse) (FinalPageReceived [ 1, 2, 3 ]) --> FinalPageReceived [2, 1]

-}
apply : (List a -> List b) -> RemoteList a -> RemoteList b
apply fn rl =
    case rl of
        NotAsked l ->
            NotAsked <| fn l

        WaitingForFirstResp l ->
            WaitingForFirstResp <| fn l

        WaitingForPage l ->
            WaitingForPage <| fn l

        FinalPageReceived l ->
            FinalPageReceived <| fn l

        WaitingOnRefresh l ->
            WaitingOnRefresh <| fn l

        RespFailed err l ->
            RespFailed err <| fn l
