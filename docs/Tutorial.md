# Tutorial

Apps using Redux maintain their whole state in an *object tree* inside a **single** store. To manipulate
such a state one has to emit `actions` which are plain JavaScript objects containg the `type` of
the given action.

The API for registering stores is `createStore` that expects a `reducer` and an optional `state`
as arguments.

Here we register a new store by calling `createStore` function and two parameters `counter` (this is the reducer)
and `1` (as the initial state)

**Hint**: *PureScript <a href="https://leanpub.com/purescript/read#leanpub-auto-curried-functions">doesn't have functions that take more than one argument</a>! I'm using JavaScript terms here
because Redux is written in JavaScript.*

```haskell
store <- (createStore counter 1)
```

A `reducer` is a function that takes a `state` and an `action` and returns a new `state`. This is
how our reducer looks like. This is a `lambda` function (a JavaScript `callback`) which is always
indicated by an `\` (it resembles the small letter λ).

```haskell
counter ::  Int -> Action -> Int
counter = \v t -> case t.type of
                        "INCREMENT" -> v + 1
                        "DECREMENT" -> v - 1
                        _ -> v
```

We also want to get immediate information regarding any state changes. Therefore we define yet another `callback`.

```haskell
callback :: forall e. Store -> Eff (reduxM :: ReduxM, console :: CONSOLE | e) Unit
callback = \store -> do
                     currentState <- (getState store)
                     log ("STATE: " ++ (unsafeCoerce currentState))
```

And we register it by using Redux' `subscribe`.

```haskell
(subscribe (callback store) store)
```

**Hint**: The argument `store` is used to `curry` the callback.

And finally we register two event handlers to react to button clicks. Here we're using <a href="http://www.ractivejs.org/" target="_blank">RactiveJS</a> and
its <a href="http://docs.ractivejs.org/latest/proxy-events" target="_blank">proxy events</a>.

*This is not mandatory as you can use any other UI-Library or Framework instead.*

```haskell
on "increment-clicked" (onIncrementClicked ract) ract
on "decrement-clicked" (onDecrementClicked ract) ract
```

Our event handler functions have the same mechanics. Only their `action` types are different.

First, we get our **store** reference from the RactiveJS component via `get "store"`. Then we use Redux'
function `dispatch` to, well, *dispatch* a new action of type `INCREMENT`. Of course, we give it the
`store` instance too.

**Hint**: *PureScript <a href="https://leanpub.com/purescript/read#leanpub-auto-runtime-data-representation">natively supports</a> JavaScript's objects.*

That's why we can simply write **{ "type" : "INCREMENT" }** *without any extra calls or conversions. Just use the good old POJOs.* :smile:

```haskell
onIncrementClicked = \r e -> do
                             store <- (get "store" r)
                             log "DISPATCH: INCREMENT"
                             action <- (dispatch { "type" : "INCREMENT" } store)
                             pure unit
```

This is how the demo app works.

Basically, it's a combination of a predictable container (Redux) with **real** pure functions and hostility towards any side-effects (PureScript).
