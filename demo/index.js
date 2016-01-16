'use strict';
var Hapi                 = require('hapi');
var path                 = require('path');
var server               = new Hapi.Server();
var Inert                = require('inert');

server.connection({ port: 8080 });

server.register(Inert, function () {});

server.route({
      path: '/content/{filename*}',
      method: 'GET',
      handler: {
        directory: {
            path: 'demo/content',
            listing: false
        }
    }
});
server.route({
      path: '/styles/{filename*}',
      method: 'GET',
      handler: {
        directory: {
            path: 'demo/styles',
            listing: false
        }
      }
});
server.route({
      path: '/scripts/{filename*}',
      method: 'GET',
      handler: {
        directory: {
            path: 'demo/scripts',
            listing: false
        }
      }
});
server.route({
      path: '/{p*}',
      method: 'GET',
      handler: function(request, reply) {
          reply.file('demo/index.html');
      }
});

/* start server */
server.start(function() {
    console.log('Server running at:', server.info.uri);
});
