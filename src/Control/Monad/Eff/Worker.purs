module Control.Monad.Eff.Worker where

import Prelude (Unit)
import Control.Monad.Eff (Eff)

foreign import data Worker :: *
foreign import data WorkerModule :: *

type Message = String
type MessageCallback e = Message -> Eff e Unit
