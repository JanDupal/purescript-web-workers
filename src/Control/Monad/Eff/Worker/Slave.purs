module Control.Monad.Eff.Worker.Slave
  ( onMessage
  , sendMessage
  ) where

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Control.Monad.Eff.Worker (WorkerModule, MessageCallback, WORKER)
import Prelude (Unit)

-- | Creates a simple Web Worker that receives incomming String messages,
-- | processed them by the supplied function and sends back result.
foreign import _onMessage :: forall a e f. (Eff e Unit -> Unit) -> MessageCallback a e -> Eff (worker :: WORKER | f) Unit

-- TODO get rid of the first parameter in favour of phantom types?
onMessage :: forall a x e f. WorkerModule a x -> MessageCallback a e -> Eff (worker :: WORKER | f) Unit
onMessage _ = _onMessage unsafePerformEff

foreign import _sendMessage :: forall a e. a -> Eff (worker :: WORKER | e) Unit

-- TODO get rid of the first parameter in favour of phantom types?
sendMessage :: forall a b e. WorkerModule a b -> b -> Eff (worker :: WORKER | e) Unit
sendMessage _ = _sendMessage
