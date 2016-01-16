## purescript-redux

<a href="http://redux.js.org/" target="_blank">Redux</a> Bindings for <a href="http://www.purescript.org/" target="_blank">PureScript</a>

A library for using the Redux state container with PureScript.

### Implementation Status

- <a href="http://redux.js.org/docs/api/createStore.html" target="_blank">createStore</a>
- <a href="http://redux.js.org/docs/api/Store.html#subscribe" target="_blank">subscribe</a>
- <a href="http://redux.js.org/docs/api/Store.html#dispatch" target="_blank">dispatch</a>
- <a href="http://redux.js.org/docs/api/Store.html#getState" target="_blank">getState</a>
- <a href="http://redux.js.org/docs/api/Store.html#replaceReducer" target="_blank">replaceReducer</a>

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

### Running

*NodeJS + Hapi*
```shell
npm start
```
*then open* <a href="http://localhost:8080">http://localhost:8080</a>

### Demo App

<img src="http://fs5.directupload.net/images/160116/4d9ovm7e.png" width="412" height="524">

### Usage

See the <a href="https://github.com/brakmic/purescript-redux/blob/master/Tutorial.md">Tutorial</a>.

### License

<a href="https://github.com/brakmic/purescript-redux/blob/master/LICENSE">MIT</a>
