module Control.Monad.Eff.Worker.Master
  ( startWorker
  , sendMessage
  , onMessage
  ) where

import Control.Monad.Eff.Worker
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Prelude (Unit)

foreign import startWorker :: forall e. WorkerModule -> Eff (worker :: WORKER | e) Worker

foreign import sendMessage :: forall e. Worker -> Message -> Eff (worker :: WORKER | e) Unit

foreign import _onMessage :: forall e f. (Eff e Unit -> Unit) -> Worker -> MessageCallback e -> Eff (worker :: WORKER | f) Unit

onMessage :: forall e f. Worker -> MessageCallback e -> Eff (worker :: WORKER | f) Unit
onMessage = _onMessage unsafePerformEff
