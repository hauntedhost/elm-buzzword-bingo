module Bingo where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String exposing (repeat, toUpper, trimRight)

newEntry phrase points id =
  {
    id = id,
    points = points,
    phrase = phrase,
    wasSpoken = False
  }

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

entryItem entry =
  li [ ]
    [
      span [ class "phrase" ] [ text entry.phrase ],
      span [ class "points" ] [ text (toString entry.points) ]
    ]

entryList =
  ul [ ]
    [
      entryItem (newEntry "Future-Proof" 100 1),
      entryItem (newEntry "Doing Agile" 200 2)
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
