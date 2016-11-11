module Main where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (AVAR, takeVar, putVar, makeVar)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (WORKER)
import Control.Monad.Eff.Worker.Master (sendMessage, onMessage, startWorker)
import Control.Monad.Rec.Class (forever)
import Echo (Request, echoWorker)


-- | SYNCHRONOUS variant of Worker API usage
echoEff :: forall e. Request -> Eff (err :: EXCEPTION, console :: CONSOLE, worker :: WORKER | e) Unit
echoEff input = do
  w <- startWorker echoWorker
  onMessage w (\m -> log $ "[PureScript - master] Worker returned: " <> show m)
  sendMessage w input

-- | ASYNCHRONOUS variant of Worker API usage
echoAff :: forall e. Request -> Aff (avar :: AVAR, console :: CONSOLE, worker :: WORKER | e) Unit
echoAff input = do
  w <- liftEff $ startWorker echoWorker
  var <- makeVar
  liftEff $ onMessage w (\m -> void $ launchAff (putVar var m))
  liftEff $ sendMessage w input
  forever $ do
    workerResult <- takeVar var
    liftEff $ log $ "[PureScript - master] Worker returned: " <> show workerResult

main :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION, worker :: WORKER | e) Unit
main = do
  log "[PureScript - master] Init"
  echoEff 42
  -- launchAff $ echoAff 42
  log "[PureScript - master] Finish"
