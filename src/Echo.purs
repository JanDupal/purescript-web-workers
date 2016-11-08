module Echo where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (takeVar, putVar, makeVar, AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (Message, WorkerModule)
import Control.Monad.Eff.Worker.Slave (onMessage, sendMessage)
import Control.Monad.Rec.Class (forever)
import Data.String (toUpper)

foreign import echoWorker :: WorkerModule

echoEff :: forall e.  Eff e Unit
echoEff = onMessage (\m -> processMessage m >>= sendMessage)

echoAff :: forall e. Aff (avar :: AVAR, console :: CONSOLE | e) Unit
echoAff = do
  var <- makeVar
  liftEff $ onMessage (\m -> void $ launchAff (putVar var m))
  forever $ do
    m <- takeVar var
    liftEff $ processMessage m >>= sendMessage

processMessage :: forall e. Message -> Eff (console :: CONSOLE | e) Message
processMessage input = do
  log $ "[PureScript - worker] Message received: " <> input
  let response = toUpper input
  log $ "[PureScript - worker] Sending message: " <> response
  pure response

-- | Name "default" is required for webworkify to work
default :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION | e) Unit
-- default = echoEff
default = void $ launchAff echoAff
