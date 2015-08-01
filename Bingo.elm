module Bingo where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (repeat, toUpper, trimRight)

title message times =
  message ++ " "
    |> toUpper
    |> repeat times
    |> trimRight
    |> text

pageHeader =
  h1 [ id "title" ] [ title "bingo!" 3]

pageFooter =
  footer []
    [ a [ href "http://seanomlor.com" ]
        [ text "Sean Omlor" ]
    ]

view =
  div [ id "container" ] [ pageHeader, pageFooter ]

main =
  view
