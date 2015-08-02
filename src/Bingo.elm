module Bingo where

import List exposing (filter, foldl, map, sortBy)
import String exposing (repeat, toUpper, trimRight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import StartApp
import BingoUtils as Utils

-- MODEL

type alias Entry =
  { id: Int,
    points: Int,
    phrase: String,
    wasSpoken: Bool
  }

type alias Model =
  { entries: List Entry,
    phraseInput: String,
    pointsInput: String,
    nextId: Int
  }

initialModel : Model
initialModel =
  { entries =
      [ newEntry "Doing Agile"     200 2,
        newEntry "Rock-Star Ninja" 400 4,
        newEntry "Future-Proof"    150 1,
        newEntry "In The Cloud"    325 3
      ],
    phraseInput = "",
    pointsInput = "",
    nextId = 5
  }

newEntry : String -> Int -> Int -> Entry
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
  | UpdatePhraseInput String
  | UpdatePointsInput String

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    Mark id   -> { model | entries <- markEntry id model.entries }
    Delete id -> { model | entries <- deleteEntry id model.entries }
    Sort      -> { model | entries <- sortEntries model.entries }

    UpdatePhraseInput contents -> { model | phraseInput <- contents }
    UpdatePointsInput contents -> { model | pointsInput <- contents }

reject : (a -> Bool) -> List a -> List a
reject fn list =
  filter (\n -> not (fn n)) list

markEntry : Int -> List Entry -> List Entry
markEntry id entries =
  let mark e =
    if e.id == id then { e | wasSpoken <- (not e.wasSpoken) } else e
  in
    map mark entries

deleteEntry : Int -> List Entry -> List Entry
deleteEntry id entries =
  reject (\e -> e.id == id) entries

sortEntries : List Entry -> List Entry
sortEntries entries =
  sortBy .points entries

-- VIEW

title : String -> Int -> Html
title message times =
  message ++ " "
    |> toUpper
    |> repeat times
    |> trimRight
    |> text

pageHeader : Html
pageHeader =
  h1 [ id "title" ] [ title "bingo!" 3 ]

pageFooter : Html
pageFooter =
  footer [ ]
    [ a [ href "http://seanomlor.com" ] [ text "Sean Omlor" ] ]

entryItem : Address Action -> Entry -> Html
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

totalPoints : List Entry -> Int
totalPoints entries =
  entries
    |> filter .wasSpoken
    |> foldl (\e sum -> sum + e.points) 0

totalItem : Int -> Html
totalItem total =
  li
    [ class "total" ]
    [ span [ class "label" ] [ text "Total"],
      span [ class "points"] [ text (toString total) ]
    ]

entryList : Address Action -> List Entry -> Html
entryList address entries =
  let
    entryItems = map (entryItem address) entries
    items = entryItems ++ [ totalItem (totalPoints entries) ]
  in
    ul [ ] items

entryForm : Address Action -> Model -> Html
entryForm address model =
  div [ ]
    [ input
        [ type' "text",
          placeholder "Phrase",
          value model.phraseInput,
          autofocus True,
          Utils.onInput address UpdatePhraseInput
        ]
        [ ],
      input
        [ type' "number",
          placeholder "Points",
          value model.pointsInput,
          Utils.onInput address UpdatePointsInput
        ]
        [ ],
      button [ class "add" ] [ text "Add" ],
      h2 [ ] [ text (model.phraseInput ++ " " ++ model.pointsInput) ]
    ]

view : Signal.Address Action -> Model -> Html
view address model =
  div [ id "container" ]
    [ pageHeader,
      entryForm address model,
      entryList address model.entries,
      button
        [ class "sort", onClick address Sort ]
        [ text "Sort" ],
      pageFooter
    ]

-- MAIN

main : Signal Html
main =
  StartApp.start {
    model  = initialModel,
    view   = view,
    update = update
  }
