module Store.RemoteList exposing (..)


type RemoteList a
    = NotAsked (List a)
    | WaitingForFirstResp (List a)
    | WaitingForPage (List a)
    | FinalPageReceived (List a)
    | WaitingOnRefresh (List a)
    | RespFailed String (List a)


waitingHelper : RemoteList a -> RemoteList a
waitingHelper rl =
    case rl of
        WaitingOnRefresh d ->
            WaitingOnRefresh d

        NotAsked d ->
            WaitingForFirstResp d

        _ ->
            WaitingForPage <| toList rl


hasFailed : RemoteList a -> Bool
hasFailed ls =
    case ls of
        RespFailed _ _ ->
            True

        _ ->
            False


hasFinished : RemoteList a -> Bool
hasFinished ls =
    case ls of
        FinalPageReceived _ ->
            True

        _ ->
            False


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


map : (a -> a) -> RemoteList a -> RemoteList a
map fn rl =
    case rl of
        NotAsked l ->
            NotAsked <| List.map fn l

        WaitingForFirstResp l ->
            WaitingForFirstResp <| List.map fn l

        WaitingForPage l ->
            WaitingForPage <| List.map fn l

        FinalPageReceived l ->
            FinalPageReceived <| List.map fn l

        WaitingOnRefresh l ->
            WaitingOnRefresh <| List.map fn l

        RespFailed err l ->
            RespFailed err <| List.map fn l


updateList : (List a -> List a) -> (List a -> List a -> List a) -> List a -> RemoteList a -> RemoteList a
updateList sortFn mergeFn newItems rl =
    case rl of
        NotAsked l ->
            NotAsked <| sortFn <| mergeFn l newItems

        WaitingForFirstResp l ->
            WaitingForFirstResp <| sortFn <| mergeFn l newItems

        WaitingForPage l ->
            WaitingForPage <| sortFn <| mergeFn l newItems

        FinalPageReceived l ->
            FinalPageReceived <| sortFn <| mergeFn l newItems

        WaitingOnRefresh l ->
            WaitingOnRefresh <| sortFn <| mergeFn l newItems

        RespFailed err l ->
            RespFailed err <| sortFn <| mergeFn l newItems


filterArchived : Bool -> RemoteList { a | is_archived : Bool } -> RemoteList { a | is_archived : Bool }
filterArchived viewingArchive data =
    data
        |> filter (\x -> x.is_archived == viewingArchive)


filter : (a -> Bool) -> RemoteList a -> RemoteList a
filter filt rl =
    case rl of
        NotAsked l ->
            NotAsked <| List.filter filt l

        WaitingForFirstResp l ->
            WaitingForFirstResp <| List.filter filt l

        WaitingForPage l ->
            WaitingForPage <| List.filter filt l

        FinalPageReceived l ->
            FinalPageReceived <| List.filter filt l

        WaitingOnRefresh l ->
            WaitingOnRefresh <| List.filter filt l

        RespFailed err l ->
            RespFailed err <| List.filter filt l
