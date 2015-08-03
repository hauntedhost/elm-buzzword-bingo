module Bingo where

import List exposing (all, filter, foldl, length, map, sortBy)
import String exposing (isEmpty, repeat, toUpper, trimRight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import Event.Extra exposing (onInput)
import List.Extra exposing (reject)
import String.Extra exposing (isPresent, parseInt)
import StartApp

-- DATA

initialEntries : List Entry
initialEntries =
  [ newEntry "Doing Agile"     200 2,
    newEntry "Rock-Star Ninja" 400 4,
    newEntry "Future-Proof"    150 1,
    newEntry "In The Cloud"    325 3
  ]

-- MODEL

type alias Entry =
  { id: Int,
    phrase: String,
    points: Int,
    wasSpoken: Bool
  }

type alias Model =
  { entries: List Entry,
    nextEntryId: Int,
    phraseInput: String,
    pointsInput: String
  }

initialModel : Model
initialModel =
  { entries = initialEntries,
    nextEntryId = initialNextEntryId,
    phraseInput = "",
    pointsInput = ""
  }

initialNextEntryId =
  let max a b = if a > b then a else b
  in foldl (\entry id -> max entry.id id) 0 initialEntries + 1

newEntry : String -> Int -> Int -> Entry
newEntry phrase points id =
  { id = id,
    phrase = phrase,
    points = points,
    wasSpoken = False
  }

newEntryFromModel : Model -> Entry
newEntryFromModel model =
  let
    phraseInput = model.phraseInput
    pointsInput = parseInt model.pointsInput
    nextEntryId = model.nextEntryId
  in
    newEntry phraseInput pointsInput nextEntryId

hasValidEntry : Model -> Bool
hasValidEntry model =
  all (\val -> isPresent val) [model.phraseInput, model.pointsInput]

-- UPDATE

type Action
  = NoOp
  | Add
  | Delete Int
  | Mark Int
  | Sort
  | UpdatePhraseInput String
  | UpdatePointsInput String

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model

    Add       -> if hasValidEntry model then addNewEntry model else model
    Delete id -> { model | entries <- deleteEntry id model.entries }
    Mark id   -> { model | entries <- markEntry id model.entries }
    Sort      -> { model | entries <- sortEntries model.entries }

    UpdatePhraseInput contents -> { model | phraseInput <- contents }
    UpdatePointsInput contents -> { model | pointsInput <- contents }

addNewEntry : Model -> Model
addNewEntry model =
  { model |
      entries     <- newEntryFromModel model :: model.entries,
      nextEntryId <- model.nextEntryId + 1,
      phraseInput <- "",
      pointsInput <- ""
  }

deleteEntry : Int -> List Entry -> List Entry
deleteEntry id entries =
  reject (\entry -> entry.id == id) entries

markEntry : Int -> List Entry -> List Entry
markEntry id entries =
  let markMatching entry =
    if | entry.id == id -> { entry | wasSpoken <- (not entry.wasSpoken) }
       | otherwise      -> entry
  in
    map markMatching entries

sortEntries : List Entry -> List Entry
sortEntries entries =
  sortBy .points entries

-- VIEW

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

pageHeader : Html
pageHeader =
  h1 [ id "title" ] [ title "bingo!" 3 ]

pageFooter : Html
pageFooter =
  footer [ ]
    [ a [ href "http://seanomlor.com" ] [ text "Sean Omlor" ] ]

title : String -> Int -> Html
title message times =
  message ++ " "
    |> toUpper
    |> repeat times
    |> trimRight
    |> text

entryForm : Address Action -> Model -> Html
entryForm address model =
  div [ ]
    [ input
        [ type' "text",
          placeholder "Phrase",
          value model.phraseInput,
          autofocus True,
          onInput address UpdatePhraseInput
        ]
        [ ],
      input
        [ type' "number",
          placeholder "Points",
          value model.pointsInput,
          onInput address UpdatePointsInput
        ]
        [ ],
      button [ class "add", onClick address Add ] [ text "Add" ],
      h2 [ ] [ text (model.phraseInput ++ " " ++ model.pointsInput) ]
    ]

entryList : Address Action -> List Entry -> Html
entryList address entries =
  let
    entryItems = map (entryItem address) entries
    items = entryItems ++ [ totalItem (totalPoints entries) ]
  in
    ul [ ] items

entryItem : Address Action -> Entry -> Html
entryItem address entry =
  li
    [ classList [ ("highlight", entry.wasSpoken) ],
      id ("entry-id-" ++ toString entry.id),
      onClick address (Mark entry.id) ]
    [ span [ class "phrase" ] [ text entry.phrase ],
      span [ class "points" ] [ text (toString entry.points) ],
      button
        [ class "delete", onClick address (Delete entry.id) ]
        [ ]
    ]

totalItem : Int -> Html
totalItem total =
  li
    [ class "total" ]
    [ span [ class "label" ] [ text "Total"],
      span [ class "points"] [ text (toString total) ]
    ]

totalPoints : List Entry -> Int
totalPoints entries =
  entries
    |> filter .wasSpoken
    |> foldl (\entry sum -> sum + entry.points) 0

-- MAIN

main : Signal Html
main =
  StartApp.start {
    model  = initialModel,
    view   = view,
    update = update
  }
