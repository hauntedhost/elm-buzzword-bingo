module Bingo where

import List exposing (filter, map, sortBy)
import String exposing (repeat, toUpper, trimRight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp

-- MODEL

initialModel =
  { entries =
      [ newEntry "Doing Agile"     200 2,
        newEntry "Rock-Star Ninja" 400 4,
        newEntry "Future-Proof"    150 1,
        newEntry "In The Cloud"    325 3
      ]
  }

newEntry phrase points id =
  { id = id,
    points = points,
    phrase = phrase,
    wasSpoken = False
  }

-- UPDATE

type Action
  = NoOp
  | Mark Int
  | Delete Int
  | Sort

update action model =
  case action of
    NoOp      -> model
    Mark id   -> { model | entries <- markEntry id model.entries }
    Delete id -> { model | entries <- deleteEntry id model.entries }
    Sort      -> { model | entries <- sortEntries model.entries }

reject fn list =
  filter (\n -> not (fn n)) list

markEntry id entries =
  let mark e = if e.id == id then { e | wasSpoken <- (not e.wasSpoken) } else e
  in map mark entries

deleteEntry id entries =
  reject (\e -> e.id == id) entries

sortEntries entries =
  sortBy .points entries

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
    [ a [ href "http://seanomlor.com" ] [ text "Sean Omlor" ] ]

entryItem address entry =
  li
    [ classList [ ("highlight", entry.wasSpoken) ],
      onClick address (Mark entry.id) ]
    [ span [ class "phrase" ] [ text entry.phrase ],
      span [ class "points" ] [ text (toString entry.points) ],
      button
        [ class "delete", onClick address (Delete entry.id) ]
        [ ]
    ]

entryList address entries =
  let entryItems = map (entryItem address) entries
  in ul [ ] entryItems

view address model =
  div [ id "container" ]
    [ pageHeader,
      entryList address model.entries,
      button
        [ class "sort", onClick address Sort ]
        [ text "Sort" ],
      pageFooter
    ]

-- MAIN

main =
  StartApp.start {
    model  = initialModel,
    view   = view,
    update = update
  }
