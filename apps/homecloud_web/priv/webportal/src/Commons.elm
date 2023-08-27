module Commons exposing (..)

import Bootstrap.Navbar as Navbar
import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import Router exposing (Route)
import Url


type Msg
    = ClickedLink UrlRequest
    | UrlChange Url.Url
    | NavbarMsg Navbar.State
    | UpdateLoginForm String String
    | ResolveHostnameSuccess String
    | Login { hostname : String, username : String, password : String}
    | LoginSuccess (IPv6, JwtToken)
    | Dir String
    | DirSuccess (List File)
    | ApiError String


type alias IPv6 = String
type alias JwtToken = String

type alias File =
    { type_ : String
    , path : String
    , size : Int
    , ctime : String
    }

type alias FormLogin =
    { hostname : String
    , username : String
    , password : String
    }

type alias Model =
    { key : Key
    , route : Maybe Route
    , ipv6 : Maybe IPv6
    , jwtToken : Maybe JwtToken
    , formLogin : FormLogin
    , files : List File
    , navbarState : Navbar.State
    }

resultToMsg : (x -> Msg) -> (a -> Msg) -> Result x a -> Msg
resultToMsg xToMsg aToMsg result =
    case result of
        Ok ok -> aToMsg ok
        Err err -> xToMsg err


authorizedEndpoint : {a | ipv6 : Maybe IPv6, jwtToken : Maybe JwtToken } -> Maybe (IPv6, JwtToken)
authorizedEndpoint model =
    Maybe.map2 Tuple.pair model.ipv6 model.jwtToken