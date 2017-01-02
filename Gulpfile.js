var path         = require('path');
var gulp         = require('gulp');
var run          = require('gulp-run');
var del          = require('del');
var changed      = require('gulp-changed');
var webpack      = require('webpack-stream');
var config       = require('./webpack.config.js');
var purescript   = require('gulp-purescript');
var projectRoot  = __dirname + '/';
var srcRoot      = 'src/';
var destRoot     = 'dest/';
var releaseRoot  = 'demo/scripts/release';

var sources = [
  "src/**/*.purs",
  "test/**/*.purs",
  "bower_components/purescript-*/src/**/*.purs",
];

var foreigns = [
  "src/**/*.js",
  "bower_components/purescript-*/src/**/*.js"
];

var demoSources = [
  "demo/scripts/**/*.purs",
  "src/**/*.purs",
  "bower_components/purescript-*/src/**/*.purs",
];

var demoForeigns = [
  "src/**/*.js",
  "demo/scripts/ui/**/*.js",
  "bower_components/purescript-*/src/**/*.js"
];

gulp.task('webpack', function() {
    return gulp.src('output/DemoApp.WithRedux/index.js')
              .pipe(webpack(config))
              .pipe(gulp.dest('./demo/scripts/release/'));
});

gulp.task("make", function () {
  return purescript.psc({ src: sources, ffi: foreigns });
});

gulp.task("make-demo", function () {
  return purescript.psc({ src: demoSources, ffi: demoForeigns });
});

gulp.task("bundle", ["make"], function () {
  return purescript.pscBundle({ src: "output/**/*.js", output: "dist/bundle.js" });
});

gulp.task("bundle-demo", ["make-demo"], function () {
  return purescript.pscBundle({ src: "output/DemoApp.WithRedux/**/*.js", output: "dist/demo/bundle.js" });
});

gulp.task("docs", function () {
  return purescript.pscDocs({
      src: sources,
      docgen: {
        "Name.Of.Module1": "docs/Name/Of/Module1.md",
        "Name.Of.Module2": "docs/Name/Of/Module2.md"
      }
    });
});

gulp.task("dotpsci-demo", function () {
  return purescript.psci({ src: demoSources, ffi: demoForeigns })
    .pipe(gulp.dest("."));
});

gulp.task("dotpsci", function () {
  return purescript.psci({ src: sources, ffi: foreigns })
    .pipe(gulp.dest("."));
});

gulp.task('clean', function (cb) {
  del([releaseRoot + '**/*'], function (err, deletedFiles) {
    if(err){
      console.log('Error during deletion: ' + err);
    }
  });
  cb();
});

gulp.task("test", ["make"], function() {
  return purescript.pscBundle({ src: "output/**/*.js", main: "Test.Main" })
    .pipe(run("node"));
});


gulp.task("build-demo", ["bundle-demo", "dotpsci-demo","webpack"]);
gulp.task("default", ["bundle", "dotpsci"]);