"use strict";

// module Control.Monad.Eff.Ractive

var Ractive = require('ractive');

//-- an ugly helper function for wiring up of callbacks
// used in push/pop APIs
var createCallback = function(api, callback){
  var cb = null;
  if(callback &&
       callback.constructor &&
       callback.constructor.name == 'Nothing'){
        cb = function(ignore){
          var ignr = ignore.then(function(){
            return {};
          }).catch(function(error){
            console.log(api + ' failed, error: ' + error);
          });
          var ret = function(){
            return ignr;
          };
          return ret;
      };
    } else {
      cb = function(val){
        return function(){
          val.then(function(v){
            callback.value0(v)();
          }).catch(function(err){
            console.log(err);
          });
          return {};
        }
      };
    }
    return cb;
};
// -- end of ugly helper function

// -- extract Ractive component settings

var extractSettings = function(settings){
  return settings.value0;
}

// -- end of extract Ractive component settings

var observe = function(selector){
  return function(handler){
    return function(options){
      if(options.constructor &&
         options.constructor.name == 'Just'){
        options = options.value0;
      } else if(options.constructor &&
         options.constructor.name == 'Nothing'){
        options = null;
      }
      return function(ractive){
        return function(){
          var cancellable = null;
          if(options){
            cancellable = ractive.observe(selector, function(n,o,kp){
                return handler(n)(o)(kp)(this);
            }, options);
          }else{
            cancellable = ractive.observe(selector, function(n,o,kp){
                return handler(n)(o)(kp)(this);
            });
          }
          return cancellable;
        };
      };
    };
  };
};

var observeOnce = function(selector){
  return function(handler){
    return function(options){
       if(options.constructor &&
         options.constructor.name == 'Just'){
        options = options.value0;
      } else if(options.constructor &&
         options.constructor.name == 'Nothing'){
        options = null;
      }
      return function(ractive){
        return function(){
          var cancellable = null;
          if(options){
            cancellable = ractive.observeOnce(selector, function(n,o,kp){
              return handler(n)(o)(kp)(this);
            }, options);
          }else{
            cancellable = ractive.observeOnce(selector, function(n,o,kp){
              return handler(n)(o)(kp)(this);
            });
          }
          return cancellable;
        };
      };
    };
  };
}

var get = function(selector){
  return function(ractive){
    return function(){
      var data = ractive.get(selector);
      return data;
    };
  };
};

var set = function(selector) {
   return function(value) {
     return function(ractive) {
       return function () {
         ractive.set(selector, value);
         return {};
     };
    };
  };
};

var on = function(event) {
 return function(handler) {
   return function(ractive) {
     return function() {
       var cancellable = ractive.on(event, function(ev){
          return handler(ev)(this);
       });
       return cancellable;
     };
   };
  };
};

var off = function(event){
  return function(handler){
    return function(ractive){
      return function(){
        var chainable = null;
        if(event.constructor &&
            event.constructor.name == 'Just'){
          chainable = ractive.off(event.value0);
        }else if(event.constructor &&
            event.constructor.name == 'Nothing'){
          chainable = ractive.off();
        }else{
          chainable = ractive.off(event.value0,handler.constructor());
        }
        return chainable;
      };
    };
  };
};

var push = function(keypath){
  return function(value){
    return function(callback){
      var cb = createCallback('push', callback);
      return function(ractive){
        return function(){
          var ok = ractive.push(keypath, value).then(function(v){
            // console.log('push, ractive promise: ' + v);
          }).catch(function(err){
            console.log('push failed, error: ' + err);
          });
          cb(ok)();
          return {};
        };
      };
    };
  };
};

var pop = function(keypath){
   return function(callback){
    var cb = createCallback('pop', callback);
    return function(ractive){
      return function(){
          var ok = ractive.pop(keypath).then(function(r){
                return r;
            }).catch(function(err){
              console.log('pop failed, error: ' + err);
          });
          cb(ok)();
          return {};
      };
    };
  };
};

var find = function(selector){
  return function(ractive){
    return function(){
      var node = ractive.find(selector);
      return node;
    };
  };
};

var findAll = function(selector){
  return function(options){
    return function(ractive){
      return function(){
        var elements = null;
        if(options &&
          options.constructor &&
          options.constructor.name == 'Nothing'){
          elements = ractive.findAll(selector);
        }else{
          elements = ractive.findAll(selector, options.value0);
        }
        return elements;
      };
    };
  };
};

var add = function(keypath){
  return function(number){
    var num = 1;
    if(number &&
      number.constructor &&
      number.constructor.name != 'Nothing'){
      num = number.value0;
    }
    return function(callback){
      var cb = createCallback('add', callback);
      return function(ractive){
        return function(){
          var ok = ractive.add(keypath, num).then(function(r){
                return r;
            }).catch(function(err){
              console.log('add failed, error: ' + err);
          });
          cb(ok)();
          return {};
        };
      };
    };
  };
};

var subtract = function(keypath){
   return function(number){
    var num = 1;
    if(number &&
      number.constructor &&
      number.constructor.name != 'Nothing'){
      num = number.value0;
    }
    return function(callback){
      var cb = createCallback('subtract', callback);
      return function(ractive){
        return function(){
          var ok = ractive.subtract(keypath, num).then(function(r){
                return r;
            }).catch(function(err){
              console.log('subtract failed, error: ' + err);
          });
          cb(ok)();
          return {};
        };
      };
    };
  };
};

var findComponent = function(name){
  return function(ractive){
    return function(){
      var component = ractive.findComponent(name);
      return component;
    }
  };
};

var findAllComponents = function(name){
  return function(options){
    if(options &&
      options.constructor &&
      options.constructor.name == 'Nothing'){
      options = null;
    }else{
      options = options.value0;
    }
    return function(ractive){
      return function(){
        var allComponents = null;
        if(options){
          allComponents = ractive.findAllComponents(name, options);
        }else{
          allComponents = ractive.find(name);
        }
        return allComponents;
      };
    };
  };
};

var animate = function(keypath){
  return function(value){
    return function(options){
      return function(ractive){
        return function(){
          if(options &&
            options.constructor &&
            options.constructor.name != 'Nothing'){
              ractive.animate(keypath,value,options).then(function(){

              }).catch(function(err){
                console.log('animate failed, error: ' + err);
              });
          }else{
            ractive.animate(keypath, value).then(function(){

            }).catch(function(err){
              console.log('animate failed, error: ' + err);
            });
          }
          return {};
        };
      };
    };
  };
};

var ractive = function(settings){
    return function(){
      var s = extractSettings(settings);
      return new Ractive(s);
    };
};

var extend = function(settings){
    return function(){
      var s = extractSettings(settings);
      var r = Ractive.extend(s);
      return r;
    };
}

module.exports = {
  get               : get,
  set               : set,
  on                : on,
  off               : off,
  push              : push,
  pop               : pop,
  observe           : observe,
  observeOnce       : observeOnce,
  find              : find,
  findAll           : findAll,
  findComponent     : findComponent,
  findAllComponents : findAllComponents,
  add               : add,
  subtract          : subtract,
  ractive           : ractive,
  extend            : extend,
  animate           : animate
}