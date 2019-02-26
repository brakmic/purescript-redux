module Test.Main where

import Prelude
import Test.QuickCheck (quickCheck, (===))
import Unsafe.Coerce (unsafeCoerce)
import Effect (Effect)
import Control.Monad.Eff.Redux (Store, Next, applyMiddleware, combineReducers, getState, dispatch)
import Debug.Trace (traceM)

-- | A simple reducer reacting to two actions: INCREMENT, DECREMENT
counter ::  forall a. Int ->
                      { "type" :: String
                      , "payload" :: String
                      | a } -> Int
counter = \v t -> case t.type of
                        "INCREMENT" -> v + 1
                        "DECREMENT" -> v - 1
                        _ -> v

-- | Additional redeucer to test combineReducer() API
counterSquared :: forall a. Int ->
                            { "type" :: String
                            , "payload" :: String
                            | a } -> Int
counterSquared = \v t -> case t.type of
                              "SQUARE_INC" -> v + (v * v)
                              "SQUARE_DEC" -> v - (v * v)
                              _ -> v

-- | Additional redeucer to test combineReducer() API
counterDoubled :: forall a. Int ->
                            { "type" :: String
                            , "payload" :: String
                            | a } -> Int
counterDoubled = \v t -> case t.type of
                              "DOUBLE_INC" -> v + (v * 2)
                              "DOUBLE_DEC" -> v - (v * 2)
                              _ -> v

-- | This is a middleware for logging
-- | It receives a subset of the Store API (getState & dispatch) and processes `actions`
simpleLogger :: forall a. Store ->
                            (Next) ->
                            { "type" :: String, "payload" :: String | a } ->
                            Effect { "type" :: String, "payload" :: String | a }
simpleLogger = \store next action -> do
                                     traceM $ "Middleware (Logger) :: Action: " <>
                                            action.type <> ", payload: " <>
                                            action.payload
                                     (next action)

-- | A simple listener for displaying current state
numericListener :: Store -> Effect Unit
numericListener = \store -> do
                     currentState <- (getState store)
                     traceM $ "STATE: " <> (unsafeCoerce currentState)

-- | Wrapper for testing the 'counter'-reducer
testReducer :: forall a. Int ->
                         { "type" :: String
                         , "payload" :: String
                         | a } -> Boolean
testReducer v a = (counter v a) /= v

-- | Wrapper for testing the 'square counter'-reducer
testSquareReducer :: forall a. Int ->
                         { "type" :: String
                         , "payload" :: String
                         | a } -> Boolean
testSquareReducer v a = (counterSquared v a) /= v

-- | Wrapper for testing the 'double counter'-reducer
testDoubleReducer :: forall a. Int ->
                         { "type" :: String
                         , "payload" :: String
                         | a } -> Boolean
testDoubleReducer v a = (counterDoubled v a) /= v

-- | Test middleware by sending actions which lead to state chages
testMiddleware :: Int -> Store -> Effect Unit
testMiddleware v store = do
                        actInc <- (dispatch { "type" : "INCREMENT", payload: v} store)
                        currentState <- (getState store)
                        traceM $ "STATE: " <> currentState
                        actDec <- (dispatch { "type" : "DECREMENT", payload: v} store)
                        currentState2 <- (getState store)
                        traceM $ "STATE: " <> currentState2
                        pure unit

main :: Effect Unit
main = do
      -- | Preparation
      --let reducers = [ counterDoubled, counterSquared ]
      let middlewares = [ simpleLogger ]
      let increment = { "type" : "INCREMENT", "payload" : "VALUE_INCR" }
      let decrement = { "type" : "DECREMENT", "payload" : "VALUE_DECR" }
      let squareInc = { "type" : "SQUARE_INC", "payload" : "VALUE_SQUARE_INC" }
      let squareDec = { "type" : "SQUARE_DEC", "payload" : "VALUE_SQUARE_DEC" }
      let doubleInc = { "type" : "DOUBLE_INC", "payload" : "VALUE_DOUBLE_DEC" }
      let doubleDec = { "type" : "DOUBLE_DEC", "payload" : "VALUE_DOUBLE_DEC" }

      traceM "\r\n[TESTING] combineReducers()"
      let combined = (combineReducers [ counterDoubled, counterSquared ])

      traceM "\r\n[TESTING] applyMiddleware()"
      -- | Try to init a new container with middleware
      store <- (applyMiddleware middlewares counter 1)
      -- | Test reducer
      traceM "\r\n[TESTING] reducer (+1 INC and DEC)"
      quickCheck \n -> (testReducer n increment) === true
      quickCheck \n -> (testReducer n decrement) === true
      traceM "\r\n[TESTING] square reducer (^2 INC and DEC)"
      quickCheck \n -> (testSquareReducer n squareInc) === true
      quickCheck \n -> (testSquareReducer n squareDec) === true
      traceM "\r\n[TESTING] double reducer (*2 INC and DEC)"
      quickCheck \n -> (testDoubleReducer n doubleInc) === true
      quickCheck \n -> (testDoubleReducer n doubleDec) === true

      traceM "\r\n[TESTING] middleware"
      -- | Test middleware
      (testMiddleware 1 store)
