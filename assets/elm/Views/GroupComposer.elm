module Views.GroupComposer exposing (view)

import GroupComposer.Parser exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style, type_, value)
import Html.Events exposing (onInput, onClick)
import Messages exposing (..)
import Models exposing (..)
import Set exposing (Set)


-- Main view


view : GroupComposerModel -> Html Msg
view model =
    let
        ( activePeople, activeGroupPks ) =
            runQuery model.groups model.people (Maybe.withDefault "" model.query)
    in
        div [ class "ui grid" ]
            [ div [ class "row" ] [ helpView ]
            , div [ class "row" ] [ queryEntry model.query ]
            , (dataView model.groups activePeople activeGroupPks)
            ]



-- Run the query to produce new group


runQuery : Groups -> PeopleSimple -> String -> ( PeopleSimple, List GroupPk )
runQuery groups people queryString =
    let
        selectedGroups =
            selectGroups queryString

        peoplePks =
            parseQueryString groups queryString
                |> applyQuery Set.empty

        result =
            people
                |> List.filter (\p -> Set.member p.pk peoplePks)
    in
        ( result, selectedGroups )



-- Query view


queryEntry : Maybe String -> Html Msg
queryEntry query =
    div [ class "sixteen wide column" ]
        [ div [ class "ui big fluid input" ]
            [ input
                [ placeholder "Query goes here: e.g. 1 + 2 - 3"
                , type_ "text"
                , onInput handleInput
                , value (Maybe.withDefault "" query)
                ]
                []
            ]
        ]


handleInput : String -> Msg
handleInput s =
    UpdateQueryString s
        |> GroupComposerMsg



-- Data view


dataView : Groups -> PeopleSimple -> List Int -> Html Msg
dataView groups people activeGroupPks =
    div [ class "row" ] [ groupsList groups activeGroupPks, groupPreview people ]



-- Group List


groupsList : Groups -> List Int -> Html Msg
groupsList groups activeGroupPks =
    div [ class "eight wide column" ]
        [ div [ class "ui raised segment" ]
            [ h4 []
                [ text "Groups"
                , div
                    [ class "circular ui grey icon right floated button"
                    ]
                    [ i [ class "icon refresh", onClick (LoadData WaitingForFirst) ] []
                    ]
                ]
            , br [] []
            , div [ class "ui divided list" ] (groups |> List.map (groupRow activeGroupPks))
            ]
        ]


groupRow : List Int -> RecipientGroup -> Html Msg
groupRow activeGroupPks group =
    div [ class "item", style (activeGroupStyle activeGroupPks group) ]
        [ div [ class "right floated content" ] [ text (toString group.pk) ]
        , div [ class "content" ] [ text group.name ]
        ]


activeGroupStyle : List Int -> RecipientGroup -> List ( String, String )
activeGroupStyle activeGroupPks group =
    if List.member group.pk activeGroupPks then
        [ ( "color", "#38AF3C" ) ]
    else
        []



-- Preview


groupPreview : PeopleSimple -> Html Msg
groupPreview people =
    div [ class "eight wide column" ]
        [ div [ class "ui raised segment" ]
            [ h4 []
                [ text "Live preview"
                , groupLink people
                ]
            , div [ class "ui list" ] (people |> List.map personRow)
            ]
        ]


personRow : RecipientSimple -> Html Msg
personRow person =
    div [ class "item" ] [ text person.full_name ]


groupLink : PeopleSimple -> Html Msg
groupLink people =
    if List.isEmpty people then
        div [] []
    else
        a
            [ class "circular ui violet icon right floated button"
            , href (buildGroupLink people)
            ]
            [ i [ class "icon mail" ] []
            ]



-- Help


helpView : Html Msg
helpView =
    div [ class "ui sixteen wide column raised segment" ]
        [ h2 [] [ text "Group Composer" ]
        , p []
            [ text "You can use this tool to \"compose\" an adhoc group." ]
        , p
            []
            [ text "Enter a query in the box below. E.g. \"1|2\" would result in a group made up of everyone in group 1 as well as everyone in group 2." ]
        , p
            []
            [ text "There are 3 operators available:" ]
        , ul
            []
            [ li [] [ b [] [ text "|" ], text " : Keep all members (union)" ]
            , li [] [ b [] [ text "+" ], text " : Keep members that are in both (intersect)" ]
            , li [] [ b [] [ text "-" ], text " : Keep member that do not exist on right hand side (diff)" ]
            ]
        , p [] [ text "The operators are applied from left to right. Use brackets to build more complex queries." ]
        , p [] [ text "The best thing to do is experiment and use the live preview." ]
        , br [] []
        , p [] [ text "Click the refresh button to reload the groups." ]
        , p [] [ text "Click the purple button to open the adhoc sending page with your group prefilled." ]
        ]



-- Build the Link


buildGroupLink : PeopleSimple -> String
buildGroupLink people =
    people
        |> List.map (\p -> "recipient=" ++ (toString p.pk))
        |> String.join "&"
        |> String.append "/send/adhoc/?"
