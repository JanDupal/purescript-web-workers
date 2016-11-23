module Echo where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Aff.Worker.Slave (send, expect, makeChan)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (WORKER, WorkerModule)
import Control.Monad.Eff.Worker.Slave (onMessage, sendMessage)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))

type Request = Int
type Response = String

foreign import echoWorker :: WorkerModule Request Response

echoEff :: forall e.  Eff (worker :: WORKER | e) Unit
echoEff = onMessage echoWorker (\m -> processMessage "Eff" m >>= sendMessage echoWorker)

echoAff :: forall e. Aff (avar :: AVAR, console :: CONSOLE, worker :: WORKER | e) Unit
echoAff = do
  Tuple rcv snd <- makeChan echoWorker
  forever $ do
    m <- expect rcv
    (liftEff $ processMessage "Aff" m) >>= send snd

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
