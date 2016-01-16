'use strict';
var webpack           = require('webpack');
var AsyncUglifyJs     = require("async-uglify-js-webpack-plugin");
var path              = require('path');
var fs                = require("fs");
var CompressionPlugin = require('compression-webpack-plugin');
var root              = __dirname + '/';
var npmRoot           = root + 'node_modules/';
var nodeScripts       = root + 'node_modules/';

var config = {
  cache: false,
  entry: {
    'app': path.resolve(__dirname, 'output/DemoApp.WithRedux/index.js')
  },
  output: {
    path: path.resolve(__dirname, 'demo/scripts/release'),
    filename: '[name].min.js',
    sourceMapFilename: '[name].min.js.map',
    library: ['DemoApp','redux']
  },
  module: {

    loaders: [
    ]
  },
   resolve: {
      extensions: ['', '.js', '.es6', '.es6.js', '.jsx', '.json', '.ts', '.css', '.html', '.ract'],
      modulesDirectories: ['node_modules', 'bower_components','output'],
      alias: {
      }
  },
  plugins: [
        new CompressionPlugin({
            asset     : '{file}.gz',
            algorithm : 'gzip',
            regExp    : /\.js$|\.html$/,
            threshold : 10240,
            minRatio  : 0.8
        }),
         new webpack.ProvidePlugin({
          'fetch': 'imports?this=>global!exports?global.fetch!whatwg-fetch'
        })
    ]
};
if (process.env.NODE_ENV === 'production') {
    config.plugins = config.plugins.concat([
    new webpack.DefinePlugin({
        'process.env': {
            NODE_ENV: JSON.stringify('production')
        }
    }),
    new AsyncUglifyJs({
      delay: 5000,
      minifyOptions: {
        mangle: false,
        warnings: true,
        compress: {
          sequences     : true,  // join consecutive statemets with the “comma operator”
          properties    : true,  // optimize property access: a["foo"] → a.foo
          dead_code     : true,  // discard unreachable code
          drop_debugger : true,  // discard “debugger” statements
          unsafe        : false, // some unsafe optimizations (see below)
          conditionals  : true,  // optimize if-s and conditional expressions
          comparisons   : true,  // optimize comparisons
          evaluate      : true,  // evaluate constant expressions
          booleans      : true,  // optimize boolean expressions
          loops         : true,  // optimize loops
          unused        : true,  // drop unused variables/functions
          hoist_funs    : true,  // hoist function declarations
          hoist_vars    : false, // hoist variable declarations
          if_return     : true,  // optimize if-s followed by return/continue
          join_vars     : true,  // join var declarations
          cascade       : true,  // try to cascade `right` into `left` in sequences
          side_effects  : true,  // drop side-effect-free statements
          warnings      : true,  // warn about potentially dangerous optimizations/code
        }
      },
      logger: false,
      done: function(path, originalContents) { }
    }),
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.OccurenceOrderPlugin(true)
  ]);
} else {
    config.devtool = '#source-map';
    config.debug   = true;
}

config.useMemoryFs = true;
config.progress = true;

module.exports = config;