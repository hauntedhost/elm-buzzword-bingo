module Bingo where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List exposing (map)
import String exposing (repeat, toUpper, trimRight)

-- MODEL

initialModel =
  {
    entries =
      [
        newEntry "Future-Proof"    150 1,
        newEntry "Doing Agile"     200 2,
        newEntry "In The Cloud"    325 3,
        newEntry "Rock-Star Ninja" 400 4
      ]
  }

newEntry phrase points id =
  {
    id = id,
    points = points,
    phrase = phrase,
    wasSpoken = False
  }

-- VIEW

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

entryList entries =
  ul [ ] (map entryItem entries)

view model =
  div [ id "container" ]
    [
      pageHeader,
      entryList model.entries,
      pageFooter
    ]

-- MAIN

main =
  view initialModel
