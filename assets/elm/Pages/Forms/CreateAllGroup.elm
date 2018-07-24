module Pages.Forms.CreateAllGroup exposing (Msg(..), update, view)

import Forms.Model exposing (Field, FormItem(FormField), FormStatus)
import Forms.View exposing (..)
import Html exposing (Html)
import Pages.Forms.Meta.CreateAllGroup exposing (meta)


-- Update


type Msg
    = UpdateGroupName String


update : Msg -> String
update (UpdateGroupName text) =
    text



-- View


type alias Messages msg =
    { form : Msg -> msg
    , postForm : msg
    }


view : Messages msg -> String -> FormStatus -> Html msg
view msgs model status =
    let
        field =
            simpleTextField (Just model) (msgs.form << UpdateGroupName)
                |> Field meta.group_name
                |> FormField

        button =
            submitButton Nothing
    in
    Html.div []
        [ Html.p [] [ Html.text "You can use this form to create a new group that contains all currently active contacts." ]
        , form status [ field ] msgs.postForm button
        ]
