module Main where

import Prelude
import Control.Monad.Aff (forkAff, launchAff, Aff)
import Control.Monad.Aff.AVar (putVar, takeVar, AVAR)
import Control.Monad.Aff.Worker.Master (makeChan)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (Worker, WORKER)
import Control.Monad.Eff.Worker.Master (sendMessage, onMessage, startWorker)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))
import Echo (Request, workerModule)


-- | SYNCHRONOUS variant of Worker API usage
echoEff :: forall a e. (Show a) => Worker Request a -> Request -> Eff (err :: EXCEPTION, console :: CONSOLE, worker :: WORKER | e) Unit
echoEff w input = do
  onMessage w (\m -> log $ "[PureScript - master Eff] Worker returned: " <> show m)
  sendMessage w input

-- | ASYNCHRONOUS variant of Worker API usage
echoAff :: forall a e. (Show a) => Worker Request a -> Request -> Aff (avar :: AVAR, console :: CONSOLE, worker :: WORKER | e) Unit
echoAff w input = do
  Tuple req res <- makeChan w
  forkAff $ forever do
    response <- takeVar res
    liftEff $ log $ "[PureScript - master Aff] Worker returned: " <> show response
  putVar req input

main :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION, worker :: WORKER | e) Unit
main = do
  log "[PureScript - master] Init"
  w1 <- startWorker workerModule
  echoEff w1 "foo"
  w2 <- startWorker workerModule
  launchAff $ echoAff w2 "bar"
  log "[PureScript - master] Finish"
