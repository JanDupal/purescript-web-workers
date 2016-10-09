module Test.Main where

import Prelude
import Control.Monad.Eff (Eff)
import Test.Assert (ASSERT, assert)

main :: forall e. Eff (assert :: ASSERT | e) Unit
main = do
  assert true
