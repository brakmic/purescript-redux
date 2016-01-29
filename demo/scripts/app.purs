module DemoApp.WithRedux where

import Prelude                   (Unit, bind, unit, pure, (-), (+), (++))
import Unsafe.Coerce             (unsafeCoerce)
import Control.Monad.Eff         (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Ractive (RactiveM, Ractive, Data(Data), on, ractive, get)
import Control.Monad.Eff.Redux   (..)

-- | A simple reducer accepting two actions: INCREMENT, DECREMENT
counter ::  forall a. Int -> { "type" :: String | a } -> Int
counter = \v t -> case t.type of
                        "INCREMENT" -> v + 1
                        "DECREMENT" -> v - 1
                        _ -> v

-- | Event handler for handling button clicks
onIncrementClicked :: forall event eff.
                      Ractive ->
                      event   ->
                      Eff (
                            ractiveM :: RactiveM,
                            reduxM   :: ReduxM,
                            console  :: CONSOLE
                            | eff
                          ) Unit
onIncrementClicked = \r e -> do
                             store <- (get "store" r)
                             action <- (dispatch { "type" : "INCREMENT", payload: "TEST INCR" } store)
                             pure unit

-- | Event handler for handling button clicks
onDecrementClicked :: forall event eff.
                        Ractive ->
                        event   ->
                        Eff (
                              ractiveM :: RactiveM,
                              reduxM   :: ReduxM,
                              console  :: CONSOLE
                              | eff
                            ) Unit
onDecrementClicked = \r e -> do
                             store <- (get "store" r)
                             action <- (dispatch { "type" : "DECREMENT", payload: "TEST DECR" } store)
                             pure unit

-- | A simple listener for displaying current state
numericListener :: forall e. Store -> Eff (reduxM :: ReduxM, console :: CONSOLE | e) Unit
numericListener = \store -> do
                     currentState <- (getState store)
                     log ("STATE: " ++ (unsafeCoerce currentState))

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
                                     log ("Middleware (Logger) :: Action: " ++
                                            action.type ++ ", payload: " ++
                                            action.payload)
                                     (next action)

-- | The app starts here
main :: forall eff. Eff
          (
            console  :: CONSOLE,
            ractiveM :: RactiveM,
            reduxM   :: ReduxM
          | eff
          )
          Unit
main = do
       -- | Create an array of middlewares
       let middlewares = [ simpleLogger ]
       -- | Initialize a Redux Store while building up a chain of middlewares
       store <- (applyMiddleware middlewares counter 1)

       -- | ALTERNATIVE (without middleware)
       -- | Create a Redux Store by wiring up the `counter` Reducer and
       -- | the initial state `1`
       ---store <- (createStore counter 1)

       -- | Define UI's properties (RactiveJS)
       -- | Notice the presence of the property `store`. This is where we
       -- | save the reference to our Redux store. On each button click this
       -- | property will be used to change the app's state.
       let appSettings = Data {
                         template : "#template",
                         el       : "#app",
                         "data" : {
                                  library   : "Redux",
                                  language  : "PureScript",
                                  logoUrl   : "./content/img/ps-logo.png",
                                  message   : "Click on the PureScript Logo!",
                                  "store"   : store,
                                  uiLib     : "RactiveJS",
                                  counter   : 0,
                                  numbers   : []
                              }
                      }
       -- | Instantiate the UI
       ract <- ractive appSettings

       -- | Subscribe with listener `numericListener`
       (subscribe (numericListener store) store)

       -- Register event-handlers
       on "increment-clicked" (onIncrementClicked ract) ract
       on "decrement-clicked" (onDecrementClicked ract) ract

       log "Demo App with Redux!"