module List.Extra where

import List exposing (filter)

reject : (a -> Bool) -> List a -> List a
reject fn list =
  filter (\n -> not (fn n)) list
