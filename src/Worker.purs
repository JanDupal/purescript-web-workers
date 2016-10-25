module Worker where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Data.String (toUpper)

-- | Creates a simple Web Worker that receives incomming String messages,
-- | processed them by the supplied function and sends back result.
foreign import initWorker :: forall a b e f. (Eff f b -> b) -> (a -> Eff f b) -> Eff e Unit

listen :: forall a b e f. (a -> Eff f b) -> Eff e Unit
listen = initWorker unsafePerformEff

-- | Name "default" is required for webworkify to work
default :: forall e. Eff e Unit
default = listen processMessage

processMessage :: String -> Eff (console :: CONSOLE) String
processMessage input = do
  log $ "[PureScript - worker] Message received: " <> input
  let response = toUpper input
  log $ "[PureScript - worker] Sending message: " <> response
  pure response
