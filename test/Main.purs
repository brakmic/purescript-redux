module Test.Main where

import Prelude                     (..)
import Test.QuickCheck             (..)
import Unsafe.Coerce               (unsafeCoerce)
import Control.Monad.Eff           (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Console   (..)
import Control.Monad.Eff.Random    (RANDOM)
import Control.Monad.Eff.Redux     (..)
import Debug.Trace                 (..)

-- | A simple reducer reacting to two actions: INCREMENT, DECREMENT
counter ::  forall a. Int -> { "type" :: String | a } -> Int
counter = \v t -> case t.type of
                        "INCREMENT" -> v + 1
                        "DECREMENT" -> v - 1
                        _ -> v

-- | This is a middleware for logging
-- | It receives a subset of the Store API (getState & dispatch) and processes `actions`
simpleLogger :: forall a e. Store ->
                            (Next) ->
                            { "type" :: String, "payload" :: String | a } ->
                            Eff (
                              reduxM :: ReduxM,
                              console :: CONSOLE
                              | e
                              )
                            { "type" :: String, "payload" :: String | a }
simpleLogger = \store next action -> do
                                     traceA $ "Middleware (Logger) :: Action: " ++
                                            action.type ++ ", payload: " ++
                                            action.payload
                                     (next action)

-- | A simple listener for displaying current state
numericListener :: forall e. Store -> Eff (reduxM :: ReduxM, console :: CONSOLE | e) Unit
numericListener = \store -> do
                     currentState <- (getState store)
                     traceA $ "STATE: " ++ (unsafeCoerce currentState)

-- | Wrapper for testing the 'counter'-reducer
testReducer :: forall a. Int -> { "type" :: String | a } -> Boolean
testReducer v a = (counter v a) /= v

-- | Test middleware by sending actions which lead to state chages
testMiddleware :: forall e. Int ->
                            Store ->
                            Eff(
                                reduxM  :: ReduxM
                              , console :: CONSOLE
                              | e) Unit
testMiddleware v store = do
                        actInc <- (dispatch { "type" : "INCREMENT", payload: v} store)
                        currentState <- (getState store)
                        traceA $ "STATE: " ++ currentState
                        actDec <- (dispatch { "type" : "DECREMENT", payload: v} store)
                        currentState2 <- (getState store)
                        traceA $ "STATE: " ++  currentState2
                        pure unit

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
      -- | Preparation
      let middlewares = [ simpleLogger ]
      let increment = { "type" : "INCREMENT" }
      let decrement = { "type" : "DECREMENT" }

      -- | Try to init a new container with middleware
      store <- (applyMiddleware middlewares counter 1)

      -- | Test reducer
      quickCheck \n -> (testReducer n increment) === true
      quickCheck \n -> (testReducer n decrement) === true

      -- | Test middleware
      (testMiddleware 1 store)