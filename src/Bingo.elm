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
  h1 [ id "title" ] [ title "bingo!" 3 ]

pageFooter =
  footer [ ]
    [
      a [ href "http://seanomlor.com" ] [ text "Sean Omlor" ]
    ]

entryItem phrase points =
  li [ ]
    [
      span [ class "phrase" ] [ text phrase ],
      span [ class "points" ] [ text (toString points) ]
    ]

entryList =
  ul [ ]
    [
      entryItem "Future-Proof" 100,
      entryItem "Doing Agile" 200
    ]

view =
  div [ id "container" ]
    [
      pageHeader,
      entryList,
      pageFooter
    ]

main =
  view
