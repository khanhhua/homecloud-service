module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.CDN
import Bootstrap.Navbar as Navbar
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col

import Bootstrap.Badge as Badge
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Table as Table

import Bootstrap.Utilities.Spacing as Spacing
import Browser exposing (Document, UrlRequest)
import Browser.Navigation exposing (Key)
import Html exposing (a, div, text)
import Html.Attributes exposing (href, style, width)
import Url

type Msg
    = ClickedLink UrlRequest
    | UrlChange Url.Url
    | NavbarMsg Navbar.State

type alias File =
    { name : String
    , size : Int
    , ctime : Int
    }

type alias Model =
    { key : Key
    , cwd : String
    , files : List File
    , navbarState : Navbar.State
    }

init : () -> Url.Url -> Key -> (Model, Cmd Msg)
init _ url key =
    let
        ( navbarState, navCmd ) =
            Navbar.initialState NavbarMsg
    in
    ( { key = key
      , cwd = "/"
      , files = []
      , navbarState = navbarState
      }
    , navCmd
    )

view : Model -> Document Msg
view model =
    { title = "Homecloud Portal"
    , body =
        [ Bootstrap.CDN.stylesheet
        , Navbar.config NavbarMsg
            |> Navbar.withAnimation
            |> Navbar.brand [ href "#" ] [ text "Homecloud Portal" ]
            |> Navbar.items
              [ Navbar.itemLink [ href "#" ] [ text "Item 1" ]
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
                    [ a [ href "#" ] [ text model.cwd ]
                    , Table.simpleTable
                        ( Table.simpleThead
                            [ Table.th [ Table.cellAttr ( style "width" "60%" ) ] [ text "Name" ]
                            , Table.th [] [ text "Size" ]
                            , Table.th [] [ text "Created at" ]
                            ]
                        , Table.tbody [] []
                        )
                    ]
                ]
            ]
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model = Navbar.subscriptions model.navbarState NavbarMsg

main : Program () Model Msg
main = Browser.application
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  , onUrlRequest = ClickedLink
  , onUrlChange = UrlChange
  }