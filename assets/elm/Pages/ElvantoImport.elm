module Pages.ElvantoImport exposing (Msg, update, view)

import Data exposing (ElvantoGroup)
import DjangoSend exposing (CSRFToken, post)
import FilteringTable as FT
import Helpers exposing (formatDate, handleNotSaved)
import Html exposing (Html, a, br, div, td, text, th, thead, tr)
import Html.Attributes as A
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Notification exposing (Notifications, createInfo, createSuccess)
import RemoteList as RL
import Rocket exposing ((=>))
import Urls


-- Update


type Msg
    = PullGroups
    | FetchGroups
    | ReceiveButtonResp (Result Http.Error Bool)


type alias UpdateProps msg =
    { topLevelMsg : Msg -> msg
    , csrftoken : CSRFToken
    }


update : UpdateProps msg -> Msg -> { a | notifications : Notifications } -> ( { a | notifications : Notifications }, List (Cmd msg) )
update props msg model =
    case msg of
        PullGroups ->
            ( { model
                | notifications =
                    createInfo model.notifications "Groups are being imported, it may take a couple of minutes"
              }
            , [ buttonReq props Urls.api_act_pull_elvanto_groups ]
            )

        FetchGroups ->
            ( { model
                | notifications =
                    createSuccess model.notifications "Groups are being fetched, it may take a couple of minutes"
              }
            , [ buttonReq props Urls.api_act_fetch_elvanto_groups ]
            )

        ReceiveButtonResp (Ok _) ->
            ( model, [] )

        ReceiveButtonResp (Err _) ->
            handleNotSaved model


buttonReq : UpdateProps msg -> String -> Cmd msg
buttonReq props url =
    post props.csrftoken url [] (Decode.succeed True)
        |> Http.send (props.topLevelMsg << ReceiveButtonResp)



-- View


type alias Props msg =
    { tableMsg : FT.Msg -> msg
    , topMsg : Msg -> msg
    , toggleElvantoGroupSync : ElvantoGroup -> msg
    }


view : Props msg -> FT.Model -> RL.RemoteList ElvantoGroup -> Html msg
view props tableModel groups =
    div []
        [ div [] [ fetchButton props, pullButton props ]
        , br [] []
        , FT.table { top = props.tableMsg } "table-striped" tableHead tableModel (groupRow props) groups
        ]


tableHead : Html msg
tableHead =
    thead []
        [ tr []
            [ th [] []
            , th [] [ text "Last Synced" ]
            , th [] [ text "Sync?" ]
            ]
        ]


fetchButton : Props msg -> Html msg
fetchButton props =
    a
        [ A.class "button button-success"
        , onClick (props.topMsg FetchGroups)
        , A.id "fetch_button"
        , A.style [ "width" => "50%" ]
        ]
        [ text "Fetch Groups" ]


pullButton : Props msg -> Html msg
pullButton props =
    a
        [ A.class "button button-info"
        , onClick (props.topMsg PullGroups)
        , A.id "pull_button"
        , A.style [ "width" => "50%" ]
        ]
        [ text "Pull Groups" ]


groupRow : Props msg -> ElvantoGroup -> ( String, Html msg )
groupRow props group =
    ( toString group.pk
    , tr []
        [ td [] [ text group.name ]
        , td [] [ text (formatDate group.last_synced) ]
        , td [] [ toggleSyncButton props group ]
        ]
    )


toggleSyncButton : Props msg -> ElvantoGroup -> Html msg
toggleSyncButton props group =
    case group.sync of
        True ->
            syncingButton props group

        False ->
            notSyncingButton props group


syncingButton : Props msg -> ElvantoGroup -> Html msg
syncingButton props group =
    button_ props "button button-success" "Syncing" group


notSyncingButton : Props msg -> ElvantoGroup -> Html msg
notSyncingButton props group =
    button_ props "button button-secondary" "Disabled" group


button_ : Props msg -> String -> String -> ElvantoGroup -> Html msg
button_ props styling label group =
    a
        [ A.class styling
        , A.id "elvantoGroupButton"
        , onClick (props.toggleElvantoGroupSync group)
        ]
        [ text label ]
