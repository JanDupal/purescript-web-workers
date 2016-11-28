module Control.Monad.Aff.Worker.Slave
  (makeChan) where

import Prelude
import Control.Monad.Aff (forkAff, launchAff, Aff)
import Control.Monad.Aff.AVar (putVar, makeVar, AVAR, AVar, takeVar)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Worker (WorkerModule, WORKER)
import Control.Monad.Eff.Worker.Slave (sendMessage, onMessage)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))

makeChan :: forall req res e. WorkerModule req res -> Aff (avar :: AVAR, worker :: WORKER | e) (Tuple (AVar req) (AVar res))
makeChan worker = do
  req <- makeVar
  liftEff $ onMessage worker (\m -> void $ launchAff (putVar req m))
  res <- makeVar
  forkAff $ forever do
    msg <- takeVar res
    liftEff $ sendMessage worker msg
  pure $ Tuple req res
