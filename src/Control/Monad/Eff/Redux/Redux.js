"use strict";

// module Control.Monad.Eff.Redux

var Redux                   = require('redux');
var createStoreInternal     = Redux.createStore;
var applyMiddlewareInternal = Redux.applyMiddleware;
var combineReducersInternal = Redux.combineReducers;

//`createStore` needs a 2-parameter, pure function for creating a new store.
//The `initialState` can be used to 'rehydrate' the client state.
var _createStore = function(reducer){
  return function(initialState){
    return function(){
      var _reducer = extractReducer(reducer);
      var store = createStoreInternal(_reducer, initialState);
      return store;
    };
  };
};

//To get information about state changes via registered `listeners`.
//http://redux.js.org/docs/api/Store.html#subscribe
var _subscribe = function(callback){
  return function(store){
    return function(){
      store.subscribe(callback);
      return {};
    };
  };
};

//Dispatches an action. A Redux-based app never changes its state directly but
//instead via so-called `actions` / `action creators`
//http://redux.js.org/docs/api/Store.html#dispatch
var _dispatch = function(action){
  return function(store){
    return function(){
      var act = {};
      if(action){
        if(action.value0){
          act = store.dispatch(action.value0);
        }else{
          act = store.dispatch(action);
        }
      }
      return act;
    };
  };
}

//Returns the current state
//http://redux.js.org/docs/api/Store.html#getState
var _getState = function(store){
  return function(){
    var s = store.getState();
    return s;
  };
};

//For replacing the current reducer.
//http://redux.js.org/docs/api/Store.html#replaceReducer
var _replaceReducer = function(store){
  return function(nextReducer){
    return function(){
      var _nextReducer = extractReducer(nextReducer);
      store.replaceReducer(_nextReducer);
    };
  };
};
//For injecting 3rd-party extensions between dispatch and reducer.
//http://redux.js.org/docs/advanced/Middleware.html
var _applyMiddleware = function(middlewares){
  var all = [],
      store;
  return function(reducer){
    return function(initialState){
      return function(){
        for (var i = 0; i < middlewares.length; ++i) {
          all.push(extractMiddleware(middlewares[i]));
        }
        //since v3.1.0 not needed anymore [https://github.com/rackt/redux/releases/tag/v3.1.0]
          /***********************************************************************************************/
          //createStoreWithMiddleware = applyMiddlewareInternal.apply(null, all)(createStoreInternal);
          //app = combineReducersInternal([reducer]); //***TODO***
          //store = createStoreWithMiddleware(extractReducer(reducer), initialState);
          /************************************************************************************************/
        store = createStoreInternal(extractReducer(reducer), initialState, applyMiddlewareInternal.apply(null, all));
        return store;
      };
    };
  };
};

//**TODO**
var combineReducers = function(){
  return {};
};
var bindActionCreators = function(){
  return {};
};

var compose = function(){
  return {};
};
//**TODO**

//INTERNALS

//-----------------------------------------------------------------------------------------------
//This is ugly but we must somehow 'extract' the two interleaved functions to create one plain JS
//function with two parameters. PureScript's functions never have more than one parameter.
//-----------------------------------------------------------------------------------------------
var extractReducer = function(reducer){
  var body     = reducer().toString();
  var arg1     = reducer.toString().split(')',1)[0].replace(/\s/g,'').substr(9).split(',');
  var arg2     = body.split(')',1)[0].replace(/\s/g,'').substr(9).split(',');
  var tmp      = body.slice(body.indexOf("{") + 1, body.lastIndexOf("}"));
  var _reducer = new Function(arg1, arg2, tmp);
  return _reducer;
};
//The `next` call is the dispatcher call and by defaul PureScript puts an additional ()-call after
//its completion (this is how PureScript wrapps effects from JS side). To maintain this extra call
//on the JS side we wrap the original next(action)-call into an additional function call.
var wrapNextDispatch = function(next){
  return function(action){
    return function(){
      next(action);
    };
  };
};
//---------------------------- EXPERIMENTAL -------------------------------------------
//Create a complete middleware function chain so redux can properly register it.
//There are three interleaved functions calls: store=>next=>action
//The `store` is not a complete store but a shrinked version of it containing only: getState & dispatch
//The `next` is the next dispatch call in the hierarchy
//The `action` is the next action to be dispatched by the current `next` dispatcher
var extractMiddleware = function(middleware){
  return function(store){
    return function(next){
      return function(action){
        var nxt = wrapNextDispatch(next);
        return middleware(store)(nxt)(action)();
      }
    };
  };
};
//-------------------------- END OF EXPERIMENTAL ---------------------------------------

//END OF INTERNALS

module.exports = {
  createStore     : _createStore,
  subscribe       : _subscribe,
  dispatch        : _dispatch,
  getState        : _getState,
  replaceReducer  : _replaceReducer,
  applyMiddleware : _applyMiddleware
};