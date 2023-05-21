module Router exposing (..)

import Url
import Url.Parser as Parser exposing ((</>), (<?>), Parser, map, oneOf, parse, s, string, top)
import Url.Parser.Query as Query

type Route
    = RouteLogin
    | RouteFileExplorer (Maybe String)

route =
    oneOf
        [ routeFileExplorer
        , routeLogin
        ]

routeFileExplorer : Parser (Route -> a) a
routeFileExplorer = map RouteFileExplorer <| s "files" <?> Query.string "q"

routeLogin = map RouteLogin top

parseUrl : Url.Url -> Maybe Route
parseUrl = Parser.parse route