module Pages.FileExplorerPage exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Navbar as Navbar
import FileListing
import Html exposing (Html, a, div, text)

import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Bootstrap.Utilities.Spacing as Spacing

import Commons exposing (Model, Msg(..))
import Html.Attributes exposing (href)
import Html exposing (p)
import Bootstrap.Button as Button


view : Model -> String -> String -> List (Html Msg)
view model hostname cwd =
    [ Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.brand [ href "#" ] [ text "Homecloud Portal" ]
        |> Navbar.items
          [ Navbar.itemLink [ href "#" ] [ text "Sign in" ]
          , Navbar.itemLink [ href "#" ] [ text "Item 2" ]
          ]
        |> Navbar.customItems
          [ Navbar.textItem [] [ text "Some text" ] ]
        |> Navbar.view model.navbarState
    , Grid.containerFluid [ Spacing.mt1 ]
        [ Grid.row []
            [ Grid.col [ Col.xs2 ]
                [ ListGroup.custom
                    [ ListGroup.button [ ListGroup.light ] [ text "Photos" ]
                    , ListGroup.button [ ListGroup.light ] [ text "Documents" ]
                    ]
                , div []
                    [ Badge.pillPrimary [ Spacing.mx1 ] [ text "#Recently added" ]
                    , Badge.pillSecondary [ Spacing.mx1] [ text "#Most visited" ]
                    ]
                ]
            , Grid.col []
                [ p []
                    ( cwd
                    |> String.split "/"
                    |> scan (\parentPath displayText ->
                        Button.linkButton
                            [ Button.light
                            , Button.attrs [ href <| "/" ++ hostname ++ "/files?q=" ++ parentPath ]
                            ] [ text displayText ]
                        )
                    )
                , FileListing.view hostname cwd model.files
                ]
            ]
        ]
    ]

dedup : List a -> List a
dedup = List.reverse << List.foldr
    (\x acc ->
    case acc of
        (y :: _) ->
            if x == y
            then acc
            else x :: acc
        [] -> [x]
    ) []
    

scan : (String -> String -> a) -> List String -> List a
scan f =
    dedup
    >> List.foldr
        (\x (s, acc) ->
            let path =
                    if s == ""
                    then "/"
                    else if s == "/"
                        then "/" ++ x
                        else s ++ "/" ++ x
                element = f path (if x == "" then "/" else x)
            in (path, element :: acc)
        ) ("", []) 
    >> Tuple.second
    >> List.reverse