module Bingo where

import Html exposing (..)
import String exposing (repeat, toUpper, trimRight)

title message times =
  message ++ " "
    |> toUpper
    |> repeat times
    |> trimRight
    |> text

main =
  title "bingo!" 3
