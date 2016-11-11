module Control.Monad.Eff.Worker.Master
  ( startWorker
  , sendMessage
  , onMessage
  ) where

import Control.Monad.Eff.Worker
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Prelude (Unit)

foreign import startWorker :: forall a b e. WorkerModule a b -> Eff (worker :: WORKER | e) (Worker a b)

foreign import sendMessage :: forall a b e. (Worker a b) -> a -> Eff (worker :: WORKER | e) Unit

foreign import _onMessage :: forall a b e f. (Eff e Unit -> Unit) -> Worker a b -> MessageCallback b e -> Eff (worker :: WORKER | f) Unit

onMessage :: forall a b e f. Worker a b -> MessageCallback b e -> Eff (worker :: WORKER | f) Unit
onMessage = _onMessage unsafePerformEff
