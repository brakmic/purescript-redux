module Effect.Ractive where

import Prelude              (Unit)
import Effect               (Effect)
import Data.Maybe           (Maybe)
import Data.Function.Uncurried (Fn1, Fn2, Fn3, runFn1, runFn2, runFn3)

data Data a b = Data {
  template :: String,
  "data"   :: { | a}
  |
  b -- optional properties like "components", "partials", "el" etc.
}

type Event = {
  node     :: DOMNode,
  original :: DOMEvent,
  keypath  :: String,
  context  :: {
    name :: String
  }
}

type ObserverEventData a b = {
  newValue :: a,
  oldValue :: b,
  keyPath  :: String
}

type RactiveEventCallback    = forall a. Ractive -> Event -> Effect a

type RactiveObserverCallback = forall a b c. a -> b -> String -> Effect c

type ObserverOptions = {
  init    :: Boolean,
  defer   :: Boolean,
  context :: Ractive
}

-- findComponents API params

type FindAllOptions = {
  live :: Boolean
}

type FindAllComponentsOptions = {
  live :: Boolean
}

-- end of findComponents API params

--  animate API params

type StepFunction = forall t value. t -> value -> Effect Unit

type CompleteFunction = forall t value. t -> value -> Effect Unit

type EasingFunction = forall t value. t -> value -> Effect Unit

data EasingParam = String | AnimateEasingFunction

type AnimateOptions = {
  duration :: Number,
  easing :: Easing,
  step :: StepFunction,
  complete :: CompleteFunction
}

-- end of anima API params

data RenderQuery             = RQString String | RQNode DOMNode

foreign import data DOMEvent    :: Type

foreign import data DOMNode     :: Type

foreign import data RactiveM    :: Type

foreign import data Ractive     :: Type

foreign import data Text        :: Type

foreign import data Element     :: Type

foreign import data Cancellable :: Type

foreign import data Easing :: Type

-- | Foreign Imports

foreign import ractive           :: forall a b. Data a b -> Effect Ractive
foreign import extend            :: forall a b. Data a b -> Effect Ractive

foreign import on                :: forall a. String -> (Event -> Effect a) -> Ractive -> Effect Cancellable
foreign import off               :: Maybe String -> Maybe RactiveEventCallback -> Ractive -> Effect Ractive

foreign import get               :: forall a. String -> Ractive -> Effect a
foreign import set               :: forall a. String -> a -> Ractive -> Effect Unit

foreign import push              :: forall a b. String -> a -> Maybe (b -> (Effect Unit)) -> Ractive -> Effect Unit
foreign import pop               :: forall a. String -> Maybe (a -> (Effect Unit)) -> Ractive -> Effect Unit

foreign import observe           :: forall a b. String -> (a -> b -> String -> (Effect Unit)) -> Maybe ObserverOptions -> Ractive -> Effect Cancellable
foreign import observeOnce       :: forall a b. String -> (a -> b -> String -> (Effect Unit)) -> Maybe ObserverOptions -> Ractive -> Effect Cancellable

foreign import find              :: String -> Ractive -> Effect DOMNode
foreign import findAll           :: String -> Maybe FindAllOptions -> Ractive -> Effect (Array DOMNode)

foreign import findComponent     :: String -> Ractive -> Effect Ractive
foreign import findAllComponents :: String -> Maybe FindAllComponentsOptions -> Ractive -> Effect (Array Ractive)

foreign import add               :: forall a. String -> Maybe Number -> Maybe (Ractive -> Effect a) -> Ractive -> Effect Unit
foreign import subtract          :: forall a. String -> Maybe Number -> Maybe (Ractive -> Effect a) -> Ractive -> Effect Unit

foreign import animate           :: forall a. String -> a -> Maybe AnimateOptions -> Ractive -> Effect Unit

foreign import ractiveFromDataImpl :: forall a b. Fn1 (Data a b) (Effect Ractive)

foreign import setPartialImpl :: Fn3 String String Ractive (Effect Unit)

foreign import getPartialImpl :: Fn2 String Ractive (Effect String)

foreign import updateModelImpl :: Fn1 Ractive (Effect Unit)

foreign import renderByIdImpl :: Fn2 String Ractive (Effect Unit)

-- | End Foreign Imports

ractiveFromData :: forall a b. Data a b -> Effect Ractive
ractiveFromData = runFn1 ractiveFromDataImpl

setPartial      :: String -> String -> Ractive -> Effect Unit
setPartial      = runFn3 setPartialImpl

getPartial      :: String -> Ractive -> Effect String
getPartial      = runFn2 getPartialImpl

updateModel     :: Ractive -> Effect Unit
updateModel     = runFn1 updateModelImpl

renderById      :: String -> Ractive -> Effect Unit
renderById      = runFn2 renderByIdImpl
