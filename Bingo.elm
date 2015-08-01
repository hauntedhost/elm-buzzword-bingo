module Bingo where

import Html
import String

main =
  "bingo!"
  |> String.toUpper
  |> String.repeat 3
  |> Html.text
