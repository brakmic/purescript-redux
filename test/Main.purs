module Test.Main where

import Prelude                     (Unit, bind, (/=), (-), (+))
import Test.QuickCheck             ((===), quickCheck)
import Control.Monad.Eff           (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Console   (CONSOLE)
import Control.Monad.Eff.Random    (RANDOM)
import Control.Monad.Eff.Redux     (ReduxM, Action)

-- | A simple reducer reacting to two actions: INCREMENT, DECREMENT
counter ::  Int -> Action -> Int
counter = \v t -> case t.type of
                        "INCREMENT" -> v + 1
                        "DECREMENT" -> v - 1
                        _ -> v

testReducer :: Int -> Action -> Boolean
testReducer v a = (counter v a) /= v

main :: forall e.
            Eff
              (
                console :: CONSOLE
              , random  :: RANDOM
              , err     :: EXCEPTION
              , reduxM  :: ReduxM
              | e
              )
              Unit
main = do
      let increment = { "type" : "INCREMENT" }
      let decrement = { "type" : "DECREMENT" }

      quickCheck \n -> (testReducer n increment) === true
      quickCheck \n -> (testReducer n decrement) === true
