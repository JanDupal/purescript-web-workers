module Main where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (AVAR, takeVar, putVar, makeVar)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Worker (Message)
import Control.Monad.Eff.Worker.Master (sendMessage, onMessage, startWorker)
import Control.Monad.Rec.Class (forever)


-- | SYNCHRONOUS variant of Worker API usage
echoEff :: forall  e. Message -> Eff (err :: EXCEPTION, console :: CONSOLE | e) Unit
echoEff input = do
  w <- startWorker
  onMessage w (\m -> log $ "[PureScript - master] Worker returned: " <> m)
  sendMessage w input

-- | ASYNCHRONOUS variant of Worker API usage
echoAff :: forall e. Message -> Aff (avar :: AVAR, console :: CONSOLE | e) Unit
echoAff input = do
  w <- liftEff $ startWorker
  var <- makeVar
  liftEff $ onMessage w (\m -> void $ launchAff (putVar var m))
  liftEff $ sendMessage w input
  forever $ do
    workerResult <- takeVar var
    liftEff $ log $ "[PureScript - master] Worker returned: " <> workerResult

main :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION | e) Unit
main = do
  log "[PureScript - master] Init"
  echoEff "payload"
  -- launchAff $ echoAff "payload"
  log "[PureScript - master] Finish"
