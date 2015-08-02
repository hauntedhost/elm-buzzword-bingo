module Bingo where

import List exposing (all, filter, foldl, length, map, sortBy)
import String exposing (isEmpty, repeat, toUpper, trimRight)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Signal exposing (Address)
import StartApp
import BingoUtils as Utils

-- MODEL

type alias Entry =
  { id: Int,
    phrase: String,
    points: Int,
    wasSpoken: Bool
  }

type alias InputFields =
  { phrase: String,
    points: String
  }

type alias Model =
  { entries: List Entry,
    nextEntryId: Int,
    inputFields: InputFields
  }

initialEntries : List Entry
initialEntries =
  [ newEntry "Doing Agile"     200 2,
    newEntry "Rock-Star Ninja" 400 4,
    newEntry "Future-Proof"    150 1,
    newEntry "In The Cloud"    325 3
  ]

initialNextEntryId =
  let max a b = if a > b then a else b
  in foldl (\e id -> max e.id id) 0 initialEntries + 1

initialModel : Model
initialModel =
  { entries = initialEntries,
    nextEntryId = initialNextEntryId,
    inputFields = {
      phrase = "",
      points = ""
    }
  }

newEntry : String -> Int -> Int -> Entry
newEntry phrase points id =
  { id = id,
    phrase = phrase,
    points = points,
    wasSpoken = False
  }

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

    UpdatePhraseInput contents ->
      let currentInputFields = model.inputFields
      in { model | inputFields <- { currentInputFields | phrase <- contents }}

    UpdatePointsInput contents ->
      let currentInputFields = model.inputFields
      in { model | inputFields <- { currentInputFields | points <- contents }}

-- TODO: generic field update function
-- updateInputField model value field =
-- ???

hasValidEntry : Model -> Bool
hasValidEntry model =
  let
    phraseInput = model.inputFields.phrase
    pointsInput = model.inputFields.points
  in
    all (\val -> isPresent val) [ phraseInput, pointsInput ]

isPresent : String -> Bool
isPresent string = not (isEmpty string)

addNewEntry : Model -> Model
addNewEntry model =
  let
    currentInputFields = model.inputFields
  in
    { model |
        nextEntryId  <- model.nextEntryId + 1,
        inputFields  <- { currentInputFields | phrase <- "", points <- "" },
        entries      <- entryFromModel model :: model.entries
    }

entryFromModel : Model -> Entry
entryFromModel model =
  let
    phraseInput = model.inputFields.phrase
    pointsInput = (Utils.parseInt model.inputFields.points)
  in
    newEntry phraseInput pointsInput model.nextEntryId

deleteEntry : Int -> List Entry -> List Entry
deleteEntry id entries =
  reject (\e -> e.id == id) entries

reject : (a -> Bool) -> List a -> List a
reject fn list =
  filter (\n -> not (fn n)) list

markEntry : Int -> List Entry -> List Entry
markEntry id entries =
  let mark entry =
    if | entry.id == id -> { entry | wasSpoken <- (not entry.wasSpoken) }
       | otherwise      -> entry
  in
    map mark entries

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
    [ id ("entry-id-" ++ toString entry.id),
      classList [ ("highlight", entry.wasSpoken) ],
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
    [ span [ class "label" ] [ text "Total" ],
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
  let
    phraseInput = model.inputFields.phrase
    pointsInput = model.inputFields.points
  in
    div [ ]
      [ input
          [ type' "text",
            placeholder "Phrase",
            value phraseInput,
            autofocus True,
            Utils.onInput address UpdatePhraseInput
          ]
          [ ],
        input
          [ type' "number",
            placeholder "Points",
            value pointsInput,
            Utils.onInput address UpdatePointsInput
          ]
          [ ],
        button [ class "add", onClick address Add ] [ text "Add" ],
        h2 [ ] [ text (phraseInput ++ " " ++ pointsInput) ]
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
