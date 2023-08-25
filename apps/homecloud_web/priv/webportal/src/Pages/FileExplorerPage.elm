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


view : Model -> String -> List (Html Msg)
view model cwd =
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
                    ( if cwd == "/" then
                        [ Button.linkButton
                            [ Button.light
                            , Button.attrs [href "#"]
                            ] [ text cwd ]
                        ]
                    else
                        [ ( String.reverse cwd
                            |> String.indexes("/")
                            |> List.take 1
                            |> List.head
                            |> Maybe.map(\index -> String.left (String.length cwd - index) cwd )
                            |> Maybe.map(\parentPath ->
                                Button.linkButton
                                    [ Button.light
                                    , Button.attrs [ href <| "/files?q=" ++ parentPath ]
                                    ] [ text "[..]" ]
                                )
                            |> Maybe.withDefault (text "")
                        )
                        , Button.linkButton
                            [ Button.light
                            , Button.attrs [href "#"]
                            ] [ text cwd ]
                        ]
                    )
                , FileListing.view model.files cwd
                ]
            ]
        ]
    ]