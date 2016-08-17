## Writing Redux-Middleware in PureScript

## A simple Logger

We will write a logger in PureScript that is similar to the one from the original Redux' <a href="http://redux.js.org/docs/advanced/Middleware.html" target="_blank">middleware docs</a>.

It looks like this:

```haskell
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
                                     log ("Middleware (Logger) :: Action: " <>
                                            action.type <> ", payload: " <>
                                            action.payload)
                                     (next action)
```

It's a function that takes:

- a `Store` (more precisely: a stripped-down of it comprising only of: `getState` & `dispatch`)
- the `Next` dispatcher call from the chain
- and an `Action` to be dispatched (it comprises of two mandatory fields: `type` & `payload`)

This function does nothing exceptionally complex but one thing is mandatory for every middleware: calling `next` with the given `Action`,
or in PureScript lingo: the application of `next` to `Action`. The return value will be yet another `dispatch` function which then will be executed by another middleware in the chain and so on until it reaches the end and the original Redux' `dispatch` gets called.

This last dispatch call will activate a **chain reaction** so that every registered middleware will execute its own logic while the `action`s fly though Redux.

### Registering the Middleware

The application one or more middlewares mandates the usage of `Store`-creation functions which are different from those we saw in the <a href="https://github.com/brakmic/purescript-redux/blob/master/docs/Tutorial.md">Tutorial</a>.

```haskell
-- | Create an array of middlewares
let middlewares = [ (simpleLogger) ]
-- | Initialize a Redux Store while building up a chain of middlewares
store <- (applyMiddleware middlewares counter 1)
```

We create an array of middlewares and call the `applyMiddleware` function which expects this array, a valid `dispatcher` and an optional `initial state`. Here we simply continue to usage
our `counter` function from the Tutorial and give `1` as the initial value.

The function `applyMiddleware` is a `foreign import` mapping to the original Redux' <a href="http://redux.js.org/docs/api/applyMiddleware.html" target="_blank">applyMiddleware</a>.

```haskell
foreign import applyMiddleware  :: forall a b c d. Array a -> (b -> Action c d -> b) -> b -> ReduxEff Store
```

As with the PureScript version the imported `applyMiddleware` expects an array of middlewares, a `dispatcher` and an optional `initial state`. It returns an *effectful* Store which is a stripped down version of the full Redux' <a href="http://redux.js.org/docs/basics/Store.html" target="_blank">Store API</a> containing only `getState` & `dispatch`.

## Using the Middleware

Now when we execute an `Action` our middleware-logger will get a change to hook into the processing chain and execute its own logic.

<img src="http://fs5.directupload.net/images/160119/z9u65jbj.png">

## Important notice

The currently implemented mappings & logic for the Middleware API are highly experimental (and very buggy!).

Therefore, please, consider it a moving target.
