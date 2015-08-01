module Bingo where

import Html
import String

main =
  Html.text (String.repeat 3 (String.toUpper "bingo!"))
