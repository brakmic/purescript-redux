module Control.Monad.Eff.Ractive where

import Prelude              (Unit, bind)
import Control.Monad.Eff    (Eff)
import Data.Maybe           (Maybe)
import Data.Foreign.EasyFFI (unsafeForeignFunction, unsafeForeignProcedure)

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

type RactiveEventCallback    = forall a e. Ractive -> Event -> Eff e a

type RactiveObserverCallback = forall a b c e. a -> b -> String -> Eff e c

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

type StepFunction = forall t value. t -> value -> RactiveEff Unit

type CompleteFunction = forall t value. t -> value -> RactiveEff Unit

type EasingFunction = forall t value. t -> value -> RactiveEff Unit

data EasingParam = String | AnimateEasingFunction

type AnimateOptions = {
  duration :: Number,
  easing :: Easing,
  step :: StepFunction,
  complete :: CompleteFunction
}

-- end of anima API params

data RenderQuery             = RQString String | RQNode DOMNode

foreign import data DOMEvent    :: *

foreign import data DOMNode     :: *

foreign import data RactiveM    :: !

foreign import data Ractive     :: *

foreign import data Text        :: *

foreign import data Element     :: *

foreign import data Cancellable :: *

foreign import data Easing :: *

type RactiveEff a = forall e. Eff (ractiveM :: RactiveM | e) a

ffiF              :: forall a. Array String -> String -> a
ffiF              = unsafeForeignFunction

ffiP              :: forall a. Array String -> String -> a
ffiP              = unsafeForeignProcedure

-- | Foreign Imports

foreign import ractive           :: forall a b. Data a b -> RactiveEff Ractive
foreign import extend            :: forall a b. Data a b -> RactiveEff Ractive

foreign import on                :: forall a e. String -> (Event -> Eff e a) -> Ractive -> RactiveEff Cancellable
foreign import off               :: Maybe String -> Maybe RactiveEventCallback -> Ractive -> RactiveEff Ractive

foreign import get               :: forall a. String -> Ractive -> RactiveEff a
foreign import set               :: forall a. String -> a -> Ractive -> RactiveEff Unit

foreign import push              :: forall a b e. String -> a -> Maybe (b -> (Eff e Unit)) -> Ractive -> RactiveEff Unit
foreign import pop               :: forall a e. String -> Maybe (a -> (Eff e Unit)) -> Ractive -> RactiveEff Unit

foreign import observe           :: forall a b e. String -> (a -> b -> String -> (Eff e Unit)) -> Maybe ObserverOptions -> Ractive -> RactiveEff Cancellable
foreign import observeOnce       :: forall a b e. String -> (a -> b -> String -> (Eff e Unit)) -> Maybe ObserverOptions -> Ractive -> RactiveEff Cancellable

foreign import find              :: String -> Ractive -> RactiveEff DOMNode
foreign import findAll           :: String -> Maybe FindAllOptions -> Ractive -> RactiveEff (Array DOMNode)

foreign import findComponent     :: String -> Ractive -> RactiveEff Ractive
foreign import findAllComponents :: String -> Maybe FindAllComponentsOptions -> Ractive -> RactiveEff (Array Ractive)

foreign import add               :: forall a e. String -> Maybe Number -> Maybe (Ractive -> Eff e a) -> Ractive -> RactiveEff Unit
foreign import subtract          :: forall a e. String -> Maybe Number -> Maybe (Ractive -> Eff e a) -> Ractive -> RactiveEff Unit

foreign import animate           :: forall a. String -> a -> Maybe AnimateOptions -> Ractive -> RactiveEff Unit

-- | End Foreign Imports

ractiveFromData :: forall a b. Data a b -> RactiveEff Ractive
ractiveFromData = ffiF ["data", ""] "new Ractive(data);"

setPartial      :: String -> String -> Ractive -> RactiveEff Unit
setPartial      = ffiP ["selector", "value", "ractive"] "ractive.partials[selector] = value;"

getPartial      :: String -> Ractive -> RactiveEff String
getPartial      = ffiF ["selector","ractive"] "ractive.partials[selector];"

updateModel     :: Ractive -> RactiveEff Unit
updateModel     = ffiP ["ractive"] "ractive.updateModel();"

renderById      :: String -> Ractive -> RactiveEff Unit
renderById      = ffiP ["id","ractive"] "ractive.render(id);"
