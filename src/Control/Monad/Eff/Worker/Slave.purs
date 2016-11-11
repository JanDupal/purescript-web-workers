module Control.Monad.Eff.Worker.Slave
  ( onMessage
  , sendMessage
  ) where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Control.Monad.Eff.Worker (Message, MessageCallback, WORKER)
import Prelude (Unit)

-- | Creates a simple Web Worker that receives incomming String messages,
-- | processed them by the supplied function and sends back result.
foreign import _onMessage :: forall e f. (Eff e Unit -> Unit) -> MessageCallback e -> Eff (worker :: WORKER | f) Unit

onMessage :: forall e f. MessageCallback e -> Eff (worker :: WORKER | f) Unit
onMessage = _onMessage unsafePerformEff

foreign import sendMessage :: forall e. Message -> Eff (worker :: WORKER | e) Unit
