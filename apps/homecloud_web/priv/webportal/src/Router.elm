module Router exposing (..)

import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, map, oneOf, s, string)
import Url.Parser.Query as Query

type Route
    = RouteLogin String
    | RouteFileExplorer String (Maybe String)

route : Parser (Route -> c) c
route =
    oneOf
        [ routeFileExplorer
        , routeLogin
        ]

routeFileExplorer : Parser (Route -> a) a
routeFileExplorer = map RouteFileExplorer <| string </>  s "files" <?> Query.string "q"

routeLogin : Parser (Route -> c) c
routeLogin = map RouteLogin string

parseUrl : Url.Url -> Maybe Route
parseUrl = Parser.parse route

getHostname : Route -> String
getHostname r =
    case r of
        RouteLogin v -> v
        RouteFileExplorer v _ -> v
        