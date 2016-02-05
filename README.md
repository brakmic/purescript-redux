## purescript-redux

<a href="http://redux.js.org/" target="_blank">Redux</a> Bindings for <a href="http://www.purescript.org/" target="_blank">PureScript</a>

A library for using the Redux state container with PureScript.

The currently supported version of Redux is <a href="https://github.com/rackt/redux/releases/tag/v3.2.1" target="_blank">v3.2.1</a>

An article describing the architecture of this library can be found <a href="http://blog.brakmic.com/managing-application-state-with-purescript-redux/">here</a>.

### Implementation Status

- <a href="http://redux.js.org/docs/api/createStore.html" target="_blank">createStore</a>
- <a href="http://redux.js.org/docs/api/Store.html#subscribe" target="_blank">subscribe</a>
- <a href="http://redux.js.org/docs/api/Store.html#dispatch" target="_blank">dispatch</a>
- <a href="http://redux.js.org/docs/api/Store.html#getState" target="_blank">getState</a>
- <a href="http://redux.js.org/docs/api/combineReducers.html" target="_blank">combineReducers</a>
- <a href="http://redux.js.org/docs/api/Store.html#replaceReducer" target="_blank">replaceReducer</a>
- <a href="http://rackt.org/redux/docs/api/applyMiddleware.html" targer="_blank">applyMiddleware</a>

This library supports <a href="https://github.com/brakmic/purescript-redux/blob/master/docs/Middleware.md">Middleware creation in PureScript</a>.

### Building

*Library*

```shell
pulp dep install [initial build only]
npm install      [initial build only]
gulp
```

*Demo App*

```shell
gulp build-demo
```

*Tests*

```shell
pulp test
```

<img src="http://fs5.directupload.net/images/160205/feb37lv7.png">

### Running

*NodeJS + Hapi*
```shell
npm start
```
*then open* <a href="http://localhost:8080">http://localhost:8080</a>

### Demo App

<img src="http://fs5.directupload.net/images/160116/4d9ovm7e.png" width="412" height="524">

### Usage

See the <a href="https://github.com/brakmic/purescript-redux/blob/master/docs/Tutorial.md">Tutorial</a>.

### License

<a href="https://github.com/brakmic/purescript-redux/blob/master/LICENSE">MIT</a>
