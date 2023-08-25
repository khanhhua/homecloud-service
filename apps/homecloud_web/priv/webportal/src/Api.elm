module Api exposing (..)

import Commons exposing (File)
import Http exposing (Error(..), Response(..), emptyBody, header, jsonBody, stringResolver)
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)


login : String -> String -> String -> Task String String
login hostname username password =
    Http.task
        { method = "POST"
        , headers = []
        , url = "/api/login"
        , body = jsonBody
            ( E.object
                [ ( "hostname", E.string hostname )
                , ( "username", E.string username )
                , ( "password", E.string password )
                ]
            )
        , resolver = stringResolver (\response ->
            case response of
                GoodStatus_ meta_ body ->
                    D.decodeString loginResponseDecoder body
                    |> Result.mapError D.errorToString
                _ -> Err "Network Issue"
            )
        , timeout = Just 30000
        }

dir : String -> String -> Task String (List File)
dir jwt path =
    Http.task
        { method = "GET"
        , headers = [header "authorization" <| "Bearer " ++ jwt]
        , url = "/api/browse?q=" ++ path
        , body = emptyBody
        , resolver = stringResolver (\response ->
            case response of
                GoodStatus_ meta_ body ->
                    D.decodeString filelistResponseDecoder body
                    |> Result.mapError D.errorToString
                _ -> Err "Network Issue"
            )
        , timeout = Just 30000
        }

loginResponseDecoder : D.Decoder String
loginResponseDecoder =
    D.field "jwt" D.string

filelistResponseDecoder : D.Decoder (List File)
filelistResponseDecoder = D.list fileDecoder

fileDecoder : D.Decoder File
fileDecoder =
    D.map4 File
        (D.field "type" D.string)
        (D.field "path" D.string)
        (D.field "size" D.int)
        (D.field "ctime" D.string)
