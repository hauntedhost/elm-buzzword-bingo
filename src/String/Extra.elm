module String.Extra where

import String exposing (isEmpty, toInt)

isPresent : String -> Bool
isPresent string = not (isEmpty string)

parseInt : String -> Int
parseInt string =
  case String.toInt string of
    Ok value ->
      value
    Err error ->
      0
