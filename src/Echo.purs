module Echo where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (takeVar, putVar, makeVar, AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (WORKER, WorkerModule)
import Control.Monad.Eff.Worker.Slave (onMessage, sendMessage)
import Control.Monad.Rec.Class (forever)

type Request = Int
type Response = String

foreign import echoWorker :: WorkerModule Request Response

echoEff :: forall e.  Eff (worker :: WORKER | e) Unit
echoEff = onMessage echoWorker (\m -> processMessage m >>= sendMessage echoWorker)

echoAff :: forall e. Aff (avar :: AVAR, console :: CONSOLE, worker :: WORKER | e) Unit
echoAff = do
  var <- makeVar
  liftEff $ onMessage echoWorker (\m -> void $ launchAff (putVar var m))
  forever $ do
    m <- takeVar var
    liftEff $ processMessage m >>= sendMessage echoWorker

processMessage :: forall a e. Show a => a -> Eff (console :: CONSOLE | e) String
processMessage input = do
  log $ "[PureScript - worker] Message received: " <> show input
  let response = "'" <> show input <> "'"
  log $ "[PureScript - worker] Sending message: " <> show response
  pure response

-- | Name "default" is required for webworkify to work
default :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION, worker :: WORKER | e) Unit
-- default = echoEff
default = void $ launchAff echoAff
