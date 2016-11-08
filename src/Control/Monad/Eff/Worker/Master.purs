module Control.Monad.Eff.Worker.Master
  ( startWorker
  , sendMessage
  , onMessage
  ) where

import Control.Monad.Eff.Worker
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Prelude (Unit)

foreign import startWorker :: forall e. Eff e Worker

foreign import sendMessage :: forall e. Worker -> Message -> Eff e Unit

-- TODO remove f param
foreign import _onMessage :: forall e f. (Eff e Unit -> Unit) -> Worker -> MessageCallback e -> Eff f Unit

-- TODO remove f param
onMessage :: forall e f. Worker -> MessageCallback e -> Eff f Unit
onMessage = _onMessage unsafePerformEff
