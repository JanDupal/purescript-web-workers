module Main where

import Prelude

import Control.Monad.Aff (Aff, makeAff, Canceler, liftEff', launchAff)

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)

foreign import startWorker :: forall e. (String -> Eff e Unit) -> String -> Eff e Unit

-- | Start a Web Worker echoing the input message.
echoWorker :: forall e. String -> Aff e String
echoWorker message = makeAff (\error success -> startWorker success message)

-- | Fire up an echo worker and log its response.
echo :: String -> Eff (err :: EXCEPTION, console :: CONSOLE) (Canceler (console :: CONSOLE))
echo input = do
  launchAff do
    workerResult <- echoWorker input
    liftEff' $ log $ "[PureScript - master] Worker returned: " <> workerResult

main :: Eff (console :: CONSOLE, err :: EXCEPTION) Unit
main = do
  log "[PureScript - master] Init"
  echo "payload"
  log "[PureScript - master] Finish"
