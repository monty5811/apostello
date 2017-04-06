module Models.FormStatus
    exposing
        ( FormStatus
            ( NoAction
            , InProgress
            , Success
            , Failed
            )
        )


type FormStatus
    = NoAction
    | InProgress
    | Success
    | Failed String
