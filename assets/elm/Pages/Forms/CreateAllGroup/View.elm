module Pages.Forms.CreateAllGroup.View exposing (view)

import DjangoSend exposing (CSRFToken)
import Forms.Model exposing (Field, FieldMeta, FormStatus)
import Forms.View exposing (..)
import Html exposing (Html)
import Messages exposing (FormMsg(CreateAllGroupMsg, PostForm), Msg(FormMsg))
import Pages.Forms.CreateAllGroup.Messages exposing (CreateAllGroupMsg(UpdateGroupName))
import Pages.Forms.CreateAllGroup.Meta exposing (meta)
import Pages.Forms.CreateAllGroup.Remote exposing (postCmd)


view : CSRFToken -> String -> FormStatus -> Html Msg
view csrf model status =
    let
        field =
            simpleTextField meta.group_name (Just model) (FormMsg << CreateAllGroupMsg << UpdateGroupName)
                |> Field meta.group_name

        button =
            submitButton Nothing (String.length model < 1)
    in
    Html.div []
        [ Html.p [] [ Html.text "You can use this form to create a new group that contains all currently active contacts." ]
        , form status [ field ] (FormMsg <| PostForm <| postCmd csrf model) button
        ]
