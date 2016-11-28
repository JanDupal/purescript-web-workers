module Control.Monad.Aff.Worker.Master
  (makeChan) where

import Prelude
import Control.Monad.Aff (forkAff, launchAff, Aff)
import Control.Monad.Aff.AVar (putVar, makeVar, AVAR, AVar, takeVar)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Worker (Worker, WORKER)
import Control.Monad.Eff.Worker.Master (sendMessage, onMessage)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))

makeChan :: forall req res e. Worker req res -> Aff (avar :: AVAR, worker :: WORKER | e) (Tuple (AVar req) (AVar res))
makeChan worker = do
  res <- makeVar
  liftEff $ onMessage worker (\m -> void $ launchAff (putVar res m))
  req <- makeVar
  forkAff $ forever do
    msg <- takeVar req
    liftEff $ sendMessage worker msg
  pure $ Tuple req res
