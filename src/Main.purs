module Main where

import Prelude
import Control.Monad.Aff (forkAff, launchAff, Aff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Aff.Worker.Master (send, expect, makeChan)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (Worker, WORKER)
import Control.Monad.Eff.Worker.Master (sendMessage, onMessage, startWorker)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))
import Echo (Request, echoWorker)


-- | SYNCHRONOUS variant of Worker API usage
echoEff :: forall a e. (Show a) => Worker Request a -> Request -> Eff (err :: EXCEPTION, console :: CONSOLE, worker :: WORKER | e) Unit
echoEff w input = do
  onMessage w (\m -> log $ "[PureScript - master Eff] Worker returned: " <> show m)
  sendMessage w input

-- | ASYNCHRONOUS variant of Worker API usage
echoAff :: forall a e. (Show a) => Worker Request a -> Request -> Aff (avar :: AVAR, console :: CONSOLE, worker :: WORKER | e) Unit
echoAff w input = do
  Tuple rcv snd <- makeChan w
  forkAff $ forever do
    workerResult <- expect rcv
    liftEff $ log $ "[PureScript - master Aff] Worker returned: " <> show workerResult
  send snd input

main :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION, worker :: WORKER | e) Unit
main = do
  log "[PureScript - master] Init"
  w1 <- startWorker echoWorker
  echoEff w1 1
  w2 <- startWorker echoWorker
  launchAff $ echoAff w2 2
  log "[PureScript - master] Finish"
