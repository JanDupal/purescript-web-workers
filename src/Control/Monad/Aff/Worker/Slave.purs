module Control.Monad.Aff.Worker.Slave
  ( expect
  , send
  , makeChan
  ) where

import Prelude
import Control.Monad.Aff (forkAff, launchAff, Aff)
import Control.Monad.Aff.AVar (putVar, makeVar, AVAR, AVar, takeVar)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Worker (WorkerModule, WORKER)
import Control.Monad.Eff.Worker.Slave (sendMessage, onMessage)
import Control.Monad.Rec.Class (forever)
import Data.Tuple (Tuple(Tuple))

type Chan a = AVar a

expect :: forall a e. Chan a -> Aff (avar :: AVAR | e) a
expect = takeVar

send :: forall a e. Chan a -> a -> Aff (avar :: AVAR | e) Unit
send = putVar

makeChan :: forall a b e. WorkerModule a b -> Aff (avar :: AVAR, worker :: WORKER | e) (Tuple (Chan a) (Chan b))
makeChan worker = do
  rcv <- makeVar
  liftEff $ onMessage worker (\m -> void $ launchAff (putVar rcv m))
  snd <- makeVar
  forkAff $ forever do
    msg <- takeVar snd
    liftEff $ sendMessage worker msg
  pure $ Tuple rcv snd
