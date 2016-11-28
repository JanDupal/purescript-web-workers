module Echo where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (putVar, takeVar, AVAR)
import Control.Monad.Aff.Worker.Slave (makeChan)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (WORKER, WorkerModule)
import Control.Monad.Eff.Worker.Slave (onMessage, sendMessage)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))

type Request = String
type Response = String

foreign import workerModule :: WorkerModule Request Response

echoEff :: forall e.  Eff (worker :: WORKER | e) Unit
echoEff = onMessage workerModule (\m -> processMessage "Eff" m >>= sendMessage workerModule)

echoAff :: forall e. Aff (avar :: AVAR, console :: CONSOLE, worker :: WORKER | e) Unit
echoAff = do
  Tuple req res <- makeChan workerModule
  forever $ do
    m <- takeVar req
    (liftEff $ processMessage "Aff" m) >>= putVar res

processMessage :: forall a e. Show a => String -> a -> Eff (console :: CONSOLE | e) String
processMessage dbg input = do
  log $ "[PureScript - worker " <> dbg <> "] Message received: " <> show input
  let response = "'" <> dbg <> " " <> show input <> "'"
  log $ "[PureScript - worker " <> dbg <> "] Sending message: " <> show response
  pure response

-- | Name "default" is required for webworkify to work
default :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION, worker :: WORKER | e) Unit
-- default = echoEff
default = void $ launchAff echoAff
