module Control.Monad.Eff.Redux
  ( Redux
  , Reducer
  , Dispatch
  , GetState
  , CreateStore
  , Next
  , Middleware
  , Store
  , Action
  , createStore
  , subscribe
  , dispatch
  , getState
  , replaceReducer
  , combineReducers
  , applyMiddleware
  ) where

import Prelude (Unit)
import Effect (Effect)

-- | Redux Objects & Effects

-- `action object` for the `dispatch`-API of `createStore`
-- according to Redux docs the action objects must have a `type` property
-- it is recommended to use string constants for `type`
type Action a b =
  { "type" :: a
  | b
  }

foreign import data Redux :: Type

foreign import data Store :: Type

type Reducer = forall a b c. a -> Action b c -> a

type Dispatch = forall a b. Action a b -> Effect (Action a b)

type GetState = forall a. Effect a

type CreateStore = forall a. Reducer -> a -> Effect Store

type Next = Dispatch

type Middleware = forall a b. Store -> Next -> (Action a b) -> Effect (Action a b)

-- | **TODO** Redux APIs (http://redux.js.org/)
foreign import createStore :: forall a b c. (a -> Action b c -> a) -> a -> Effect Store

foreign import subscribe :: (Effect Unit) -> Store -> Effect Unit

foreign import dispatch :: forall a b. Action a b -> Store -> Effect (Action a b)

foreign import getState :: forall a. Store -> Effect a

foreign import replaceReducer :: Reducer -> Store -> Effect Unit

foreign import combineReducers :: forall a b c. Array (a -> Action b c -> a) -> Effect Reducer

foreign import applyMiddleware :: forall a b c d. Array a -> (b -> Action c d -> b) -> b -> Effect Store
