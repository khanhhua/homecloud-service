module FileListing exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (style)

import Bootstrap.Table as Table

import Commons exposing (File)
import Html.Attributes exposing (href)
import Html exposing (a)


view : String -> String -> List File -> Html msg
view hostname cwd files =
    let
        length = String.length cwd
    in
    Table.simpleTable
        ( Table.simpleThead
            [ Table.th [ Table.cellAttr ( style "width" "60%" ) ] [ text "Name" ]
            , Table.th [] [ text "Size" ]
            , Table.th [] [ text "Created at" ]
            ]
        , Table.tbody []
            ( files
            |> List.map (\file ->
                let displayText = String.dropLeft length file.path
                in Table.tr []
                    [ Table.td []
                        [ case file.type_ of
                            "dir" ->
                                a [ href <| "/" ++ hostname ++ "/files?q=" ++ file.path ]
                                    [ text displayText
                                    ]
                            _ -> text displayText
                        ]
                    , Table.td [] [ text <| String.fromInt file.size  ]
                    , Table.td [] [ text file.ctime ]
                    ]
                )
            )
        )