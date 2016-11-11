module Control.Monad.Eff.Worker where

import Prelude (Unit)
import Control.Monad.Eff (Eff)

foreign import data WORKER :: !

-- TODO accept only Transferable types
foreign import data Worker :: * -> * -> *
foreign import data WorkerModule :: * -> * -> *

type MessageCallback a e = a -> Eff e Unit
