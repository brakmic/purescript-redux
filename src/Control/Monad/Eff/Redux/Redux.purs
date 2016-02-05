module Control.Monad.Eff.Redux where

import Prelude              (Unit)
import Control.Monad.Eff    (Eff)
import Data.Foreign.EasyFFI (unsafeForeignFunction, unsafeForeignProcedure)

-- | Redux Objects & Effects

-- `action object` for the `dispatch`-API of `createStore`
-- according to Redux docs the action objects must have a `type` property
-- it is recommended to use string constants for `type`
type Action a b = {
  "type" :: a
  | b
}

foreign import data ReduxM :: !

foreign import data Redux  :: *

foreign import data Store  :: *

type ReduxEff a  = forall e. Eff (reduxM :: ReduxM | e) a

type Reducer     = forall a b c. a -> Action b c -> a

type Dispatch    = forall a b. Action a b -> ReduxEff (Action a b)

type GetState    = forall a. ReduxEff a

type CreateStore = forall a. Reducer -> a -> ReduxEff Store

type Next        = Dispatch

type Middleware  = forall a b. Store -> Next -> (Action a b) -> ReduxEff (Action a b)

-- | FFI Calls / Shortcuts
ffiF :: forall a. Array String -> String -> a
ffiF = unsafeForeignFunction

ffiP :: forall a. Array String -> String -> a
ffiP = unsafeForeignProcedure

-- | **TODO** Redux APIs (http://redux.js.org/)
foreign import createStore      :: forall a b c. (a -> Action b c -> a) -> a -> ReduxEff Store

foreign import subscribe        :: forall e. (Eff e Unit) -> Store -> ReduxEff Unit

foreign import dispatch         :: forall a b. Action a b -> Store -> ReduxEff (Action a b)

foreign import getState         :: forall a. Store -> ReduxEff a

foreign import replaceReducer   :: Reducer -> Store -> ReduxEff Unit

foreign import combineReducers  :: forall a b c. Array (a -> Action b c -> a) -> ReduxEff Reducer

foreign import applyMiddleware  :: forall a b c d. Array a -> (b -> Action c d -> b) -> b -> ReduxEff Store