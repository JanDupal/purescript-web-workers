module Main where

import Prelude
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.AVar (AVAR, takeVar, putVar, makeVar)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Control.Monad.Rec.Class (forever)

type Message = String

foreign import data Worker :: *

foreign import _startWorker :: forall e. Eff e Worker

foreign import _sendMessage :: forall e. Worker -> Message -> Eff e Unit

type MessageCallback e = Message -> Eff e Unit

-- TODO remove f param
foreign import _onMessage :: forall e f. (Eff e Unit -> Unit) -> Worker -> MessageCallback e -> Eff f Unit

-- TODO remove f param
onMessage :: forall e f. Worker -> MessageCallback e -> Eff f Unit
onMessage = _onMessage unsafePerformEff

-- | SYNCHRONOUS variant of Worker API usage
echoEff :: forall  e. Message -> Eff (err :: EXCEPTION, console :: CONSOLE | e) Unit
echoEff input = do
  w <- _startWorker
  onMessage w (\m -> log $ "[PureScript - master] Worker returned: " <> m)
  _sendMessage w input

-- | ASYNCHRONOUS variant of Worker API usage
echoAff :: forall e. Message -> Aff (avar :: AVAR, console :: CONSOLE | e) Unit
echoAff input = do
  w <- liftEff $ _startWorker
  var <- makeVar
  liftEff $ onMessage w (\m -> void $ launchAff (putVar var m))
  liftEff $ _sendMessage w input
  forever $ do
    workerResult <- takeVar var
    liftEff $ log $ "[PureScript - master] Worker returned: " <> workerResult

main :: forall e. Eff (avar :: AVAR, console :: CONSOLE, err :: EXCEPTION | e) Unit
main = do
  log "[PureScript - master] Init"
  echoEff "payload"
  -- launchAff $ echoAff "payload"
  log "[PureScript - master] Finish"
