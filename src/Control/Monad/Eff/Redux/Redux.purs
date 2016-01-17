module Control.Monad.Eff.Redux where

import Prelude              (Unit, bind)
import Control.Monad.Eff    (Eff)
import Data.Foreign.EasyFFI (unsafeForeignFunction, unsafeForeignProcedure)

-- | Redux Objects & Effects

-- `action object` for the `dispatch`-API of `createStore`
-- according to Redux docs the action objects must have a `type` property
-- it is recommended to use string constants for `type`
type Action a = {
  "type" :: String
  | a
}

foreign import data ReduxM :: !

foreign import data Redux  :: *

foreign import data Store  :: *

type ReduxEff a = forall e. Eff (reduxM :: ReduxM | e) a

type Reducer    = forall a b. a -> Action b -> a

-- | FFI Calls / Shortcuts
ffiF :: forall a. Array String -> String -> a
ffiF = unsafeForeignFunction

ffiP :: forall a. Array String -> String -> a
ffiP = unsafeForeignProcedure

-- | **TODO** Redux APIs (http://redux.js.org/)
foreign import createStore      :: forall a b. (a -> Action b -> a) -> a -> ReduxEff Store

foreign import subscribe        :: forall e. (Eff e Unit) -> Store -> ReduxEff Unit

foreign import dispatch         :: forall a. Action a -> Store -> ReduxEff (Action a)

foreign import getState         :: forall a. Store -> ReduxEff a

foreign import replaceReducer   :: Reducer -> Store -> ReduxEff Unit