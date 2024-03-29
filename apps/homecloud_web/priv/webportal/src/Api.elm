module Api exposing (..)

import Commons exposing (File)
import Http exposing (Error(..), Response(..), emptyBody, header, jsonBody, stringResolver)
import Json.Decode as D
import Json.Encode as E
import Task exposing (Task)
import Commons exposing (IPv6, JwtToken)


resolveHostname : String -> Task String String
resolveHostname hostname =
    Http.task
        { method = "GET"
        , headers = []
        , url = "/api/devices/" ++ hostname
        , body = Http.emptyBody
        , resolver = stringResolver (\response ->
            case response of
                GoodStatus_ meta_ body ->
                    D.decodeString hostnameResponseDecoder body
                    |> Result.mapError D.errorToString
                _ -> Err "Network Issue"
            )
        , timeout = Just 30000
        }

login : IPv6 -> String -> String -> Task String (IPv6, JwtToken)

login ipv6 username password =
    Http.task
        { method = "POST"
        , headers = []
        , url = "http://" ++ ipv6 ++ ":8080/api/login"
        , body = jsonBody
            ( E.object
                [ ( "username", E.string username )
                , ( "password", E.string password )
                ]
            )
        , resolver = stringResolver (\response ->
            case response of
                GoodStatus_ meta_ body ->
                    D.decodeString
                        (   loginResponseDecoder
                            |> D.map (\token -> (ipv6, token))
                        ) body
                    |> Result.mapError D.errorToString
                _ -> Err "Network Issue"
            )
        , timeout = Just 30000
        }

dir : (String, String) -> String -> Task String (List File)
dir (ipv6, jwt) path =
    Http.task
        { method = "GET"
        , headers = [header "authorization" <| "Bearer " ++ jwt]
        , url = "http://" ++ ipv6 ++ ":8080/api/browse?q=" ++ path
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

hostnameResponseDecoder : D.Decoder String
hostnameResponseDecoder =
    D.field "data" <| D.field "ipv6" D.string

loginResponseDecoder : D.Decoder String
loginResponseDecoder =
    D.field "data" <| D.field "jwt" D.string

filelistResponseDecoder : D.Decoder (List File)
filelistResponseDecoder =
    D.field "data" <| D.list fileDecoder

fileDecoder : D.Decoder File
fileDecoder =
    D.map4 File
        (D.field "type" D.string)
        (D.field "path" D.string)
        (D.field "size" D.int)
        (D.field "ctime" D.string)
