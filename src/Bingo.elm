module Bingo where

import List exposing (filter, map, sortBy)
import String exposing (repeat, toUpper, trimRight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import StartApp

-- MODEL

initialModel =
  {
    entries =
      [
        newEntry "Doing Agile"     200 2,
        newEntry "Rock-Star Ninja" 400 4,
        newEntry "Future-Proof"    150 1,
        newEntry "In The Cloud"    325 3
      ]
  }

newEntry phrase points id =
  {
    id = id,
    points = points,
    phrase = phrase,
    wasSpoken = False
  }

-- UPDATE

type Action
  = NoOp
  | Delete Int
  | Sort

reject fn list =
  filter (\n -> not (fn n)) list

-- examples:
-- rejectBy String.length 3 [ "hello", "abc", "goodbye" ]
-- rejectBy .id 2 [ { id = 1, name = "sean" }, { id = 2, name = "alli" } ]
rejectBy property value list =
  reject (\item -> (property item) == value) list

update action model =
  case action of
    NoOp      -> model
    Sort      -> { model | entries <- sortBy .points model.entries }
    Delete id -> { model | entries <- rejectBy .id id model.entries }

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

entryItem address entry =
  li [ ]
    [
      span [ class "phrase" ] [ text entry.phrase ],
      span [ class "points" ] [ text (toString entry.points) ],
      button
        [ class "delete", onClick address (Delete entry.id) ]
        [ ]
    ]

entryList address entries =
  let
    entryItems = map (entryItem address) entries
  in
    ul [ ] entryItems

view address model =
  div [ id "container" ]
    [
      pageHeader,
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
