module Pages.LoginPage exposing (..)

import Bootstrap.Grid as Grid
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Utilities.Spacing as Spacing
import Bootstrap.Utilities.Border as Border
import Commons exposing (FormLogin, Msg(..))
import Html exposing (Html, h3, text)
import Html.Attributes exposing (class)
import Html.Attributes exposing (href)
import Html exposing (a)


view : FormLogin -> Html Msg
view formLogin =
    Grid.container [ Spacing.pt5 ]
        [ Grid.row []
            [ Grid.col [ Col.xs5, Col.attrs [Spacing.mxAuto] ]
                [ Form.form [ Border.all, Border.secondary, Border.rounded, Spacing.p3 ]
                    [ h3 [ Spacing.mb4, class "text-center" ] [ text "Login to your Homecloud" ]
                    , Form.group []
                        [ Input.text
                            [ Input.onInput (UpdateLoginForm "username")
                            , Input.placeholder "Username"
                            ]
                        ]
                    , Form.group []
                        [ Input.password
                            [ Input.onInput (UpdateLoginForm "password")
                            , Input.placeholder "Password"
                            ]
                        ]
                    , Button.button
                        [ Button.primary
                        , Button.block
                        , Button.onClick (Login formLogin)
                        ]
                        [ text "Log in" ]
                    ]
                ]
            ]
        ]
