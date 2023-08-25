module Main exposing (..)

import Bootstrap.CDN
import Bootstrap.Navbar as Navbar

import Browser exposing (Document)
import Browser.Navigation exposing (Key, replaceUrl)

import Html exposing (h1, text)
import Html.Attributes exposing (class)
import Task
import Url

import Api
import Commons exposing (Model, Msg(..), resultToMsg)
import Pages.FileExplorerPage as FileExplorerPage
import Pages.LoginPage as LoginPage
import Router exposing (Route(..), parseUrl)
import Browser exposing (UrlRequest(..))
import Browser.Navigation exposing (pushUrl)
import Tuple exposing (pair)


init : () -> Url.Url -> Key -> (Model, Cmd Msg)
init _ url key =
    let
        ( navbarState, navCmd ) =
            Navbar.initialState NavbarMsg
        route = parseUrl url
    in
    ( { key = key
      , route = route
      , jwt = Nothing
      , formLogin = { hostname = "", username = "", password = "" }
      , files = []
      , navbarState = navbarState
      }
    , navCmd
    )

view : Model -> Document Msg
view model =
    { title = "Homecloud Portal"
    , body =
        Bootstrap.CDN.stylesheet
        ::
        ( Maybe.map (\route ->
            case route of
                RouteLogin -> [ LoginPage.view model.formLogin ]
                RouteFileExplorer path -> FileExplorerPage.view model (path |> Maybe.withDefault "/")
            )
            model.route
        |> Maybe.withDefault [ h1 [ class "text-center" ] [ text "Nice try!" ] ]
        )
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChange url ->
            let
                route = parseUrl url
                cmd = Maybe.map2 (\route_ jwt ->
                        case route_ of
                            RouteFileExplorer path ->
                                Api.dir jwt (path |> Maybe.withDefault "/")
                                |> Task.attempt (resultToMsg ApiError DirSuccess)
                            _ -> Cmd.none
                        )
                        route
                        model.jwt
                    |> Maybe.withDefault Cmd.none
            in
            ( { model | route = route }, cmd )
        ClickedLink urlRequest ->
            case urlRequest of
                Internal url ->
                    let
                        mbRoute = parseUrl url
                        cmds = Maybe.map2 pair mbRoute model.jwt
                            |> Maybe.andThen (\(route, jwt) ->
                                case route of
                                    RouteFileExplorer mbPath ->
                                        mbPath
                                        |> Maybe.map (\path -> (path, jwt))
                                        |> Maybe.withDefault ("/", jwt)
                                        |> Just
                                    _ -> Nothing
                            )
                            |> Maybe.map (\(path, jwt) ->
                                Api.dir jwt path
                                |> Task.attempt (resultToMsg ApiError DirSuccess)
                            )
                            |> Maybe.map (\dirCommand ->
                                [ pushUrl model.key <| Url.toString url
                                , dirCommand
                                ]
                            )
                            |> Maybe.withDefault [ pushUrl model.key <| Url.toString url]
                    in 
                    ( { model | route = mbRoute }, Cmd.batch cmds )
                _ -> ( model, Cmd.none )
        UpdateLoginForm field value ->
            let
                formLogin = model.formLogin
                updatedForm = case field of
                    "hostname" -> {formLogin | hostname = value}
                    "username" -> {formLogin | username = value}
                    "password" -> {formLogin | password = value}
                    _ -> formLogin
            in
                ( { model | formLogin = updatedForm }, Cmd.none )
        Login loginForm ->
            ( model
            , Api.login loginForm.hostname loginForm.username loginForm.password
                |> Task.attempt (resultToMsg ApiError LoginSuccess)
            )
        LoginSuccess jwt ->
            ( { model | jwt = Just jwt }, replaceUrl model.key "/files?q=/")
        DirSuccess files ->
            ( { model | files = files }, Cmd.none)
        _ ->
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