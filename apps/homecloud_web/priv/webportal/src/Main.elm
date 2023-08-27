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
import Commons exposing (JwtToken)
import Commons exposing (authorizedEndpoint)
import Router exposing (getHostname)

type alias Flags = Maybe JwtToken

init : Flags -> Url.Url -> Key -> (Model, Cmd Msg)
init mbJwtToken url key =
    let
        ( navbarState, navCmd ) =
            Navbar.initialState NavbarMsg
        mbRoute = parseUrl url
        cmds = [ navCmd
               , mbRoute
                |> Maybe.map (\route ->
                    case route of
                        RouteLogin hostname -> hostname
                        RouteFileExplorer hostname _ -> hostname
                )
                |> Maybe.map (Api.resolveHostname >> Task.attempt (resultToMsg ApiError ResolveHostnameSuccess))
                |> Maybe.withDefault Cmd.none
                ]
    in
    ( { key = key
      , route = mbRoute
      , ipv6 = Nothing
      , jwtToken = mbJwtToken
      , formLogin = { hostname = "", username = "", password = "" }
      , files = []
      , navbarState = navbarState
      }
    , Cmd.batch cmds
    )

view : Model -> Document Msg
view model =
    { title = "Homecloud Portal"
    , body =
        Bootstrap.CDN.stylesheet
        ::
        ( Maybe.map (\route ->
            case route of
                RouteLogin _ -> [ LoginPage.view model.formLogin ]
                RouteFileExplorer hostname path -> FileExplorerPage.view model hostname (path |> Maybe.withDefault "/")
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
                cmd = ( Maybe.map2 (\route_ authorizedEndpoint ->
                        case route_ of
                            RouteFileExplorer _ path ->
                                Api.dir authorizedEndpoint (path |> Maybe.withDefault "/")
                                |> Task.attempt (resultToMsg ApiError DirSuccess)
                            _ -> Cmd.none
                        )
                        route
                        <| authorizedEndpoint model
                    )
                    |> Maybe.withDefault Cmd.none
            in
            ( { model | route = route }, cmd )
        ClickedLink urlRequest ->
            case urlRequest of
                Internal url ->
                    let
                        mbRoute = parseUrl url
                        cmds = ( Maybe.map2 pair (authorizedEndpoint model) mbRoute)
                            |> Maybe.andThen (\(endpoint, route) ->
                                case route of
                                    RouteFileExplorer _ mbPath ->
                                        mbPath
                                        |> Maybe.map (\path -> (endpoint, path))
                                        |> Maybe.withDefault (endpoint, "/")
                                        |> Just
                                    _ -> Nothing
                            )
                            |> Maybe.map (\(endpoint, path) ->
                                Api.dir endpoint path
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
        ResolveHostnameSuccess ipv6 ->
            ( { model | ipv6 = Just ipv6 }, Cmd.none )
        Login loginForm ->
            ( model
            , model.ipv6
                |> Maybe.map (\ipv6 -> Api.login ipv6 loginForm.username loginForm.password)
                |> ( Maybe.map <| Task.attempt (resultToMsg ApiError LoginSuccess) )
                |> Maybe.withDefault Cmd.none
            )
        LoginSuccess (ipv6, jwt) ->
            let hostname = model.route |> Maybe.map getHostname |> Maybe.withDefault ""
            in
            ( { model | ipv6 = Just ipv6, jwtToken = Just jwt }
            , replaceUrl model.key <| "/" ++ hostname ++  "/files?q=/"
            )
        DirSuccess files ->
            ( { model | files = files }, Cmd.none)
        _ ->
            ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model = Navbar.subscriptions model.navbarState NavbarMsg

main : Program Flags Model Msg
main = Browser.application
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  , onUrlRequest = ClickedLink
  , onUrlChange = UrlChange
  }