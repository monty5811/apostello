port module Biu exposing (..)


type alias BiuMsg =
    { content : String
    , msgType : String
    }


biuNotSaved : Cmd msg
biuNotSaved =
    biuWarning "Something went wrong, there :-( Your changes may not have been saved"


biuLoadingFailed : Cmd msg
biuLoadingFailed =
    biuWarning "We couldn't reach the server, we'll try again in a bit..."


biuWarning : String -> Cmd msg
biuWarning msg =
    showMessage (BiuMsg msg "warning")


biuInfo : String -> Cmd msg
biuInfo msg =
    showMessage (BiuMsg msg "info")


biuSuccess : String -> Cmd msg
biuSuccess msg =
    showMessage (BiuMsg msg "success")


port showMessage : BiuMsg -> Cmd msg
