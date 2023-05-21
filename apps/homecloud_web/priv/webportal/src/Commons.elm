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
    | Login { hostname : String, username : String, password : String}
    | LoginSuccess String
    | Dir String
    | DirSuccess (List File)
    | ApiError String

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
    , jwt : Maybe String
    , formLogin : FormLogin
    , files : List File
    , navbarState : Navbar.State
    }

resultToMsg : (x -> Msg) -> (a -> Msg) -> Result x a -> Msg
resultToMsg xToMsg aToMsg result =
    case result of
        Ok ok -> aToMsg ok
        Err err -> xToMsg err