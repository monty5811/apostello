module Pages.Fragments.Loader exposing (loader)

import Html
import Html.Attributes as A


loader : Html.Html msg
loader =
    Html.div [ A.class "spinner" ]
        [ Html.div [ A.class "dot1" ] []
        , Html.div [ A.class "dot2" ] []
        ]
