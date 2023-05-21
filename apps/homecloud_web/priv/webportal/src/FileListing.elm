module FileListing exposing (..)

import Html exposing (Html, text)
import Html.Attributes exposing (style)

import Bootstrap.Table as Table

import Commons exposing (File)


view : List File -> String -> Html msg
view files cwd =
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
                Table.tr []
                    [ Table.td [] [ text <| String.dropLeft length file.path ]
                    , Table.td [] [ text <| String.fromInt file.size  ]
                    , Table.td [] [ text file.ctime ]
                    ]
                )
            )
        )