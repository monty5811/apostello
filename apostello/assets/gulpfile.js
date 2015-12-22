var gulp = require('gulp'),
  plumber = require('gulp-plumber'),
  rename = require('gulp-rename'),
  minifycss = require('gulp-minify-css'),
  sass = require('gulp-sass'),
  gutil = require("gulp-util"),
  webpack = require("webpack"),
  // require tasks as dependencies
  uiBuildCss = require('./semantic/tasks/build/css'),
  uiBuildJs = require('./semantic/tasks/build/javascript');

gulp.task('uiBuildCss', uiBuildCss);
gulp.task('uiBuildJs', uiBuildJs);

gulp.task('build-ui', ['uiBuildCss', 'uiBuildJs']);

gulp.task('copyThemeFonts', function() {
  gulp.src([
      './semantic/src/themes/default/assets/fonts/*.*',
    ])
    .pipe(gulp.dest('./../static/css/themes/default/assets/fonts'));
});

gulp.task('css', ['uiBuildCss', 'copyThemeFonts'], function() {
  gulp.src([
      './css/**/*.scss',
    ])
    .pipe(plumber({
      errorHandler: function(error) {
        console.log(error.message);
        this.emit('end');
      }
    }))
    .pipe(sass({
      style: 'compressed',
      includePaths: [
        './semantic/dist/semantic.css',
      ]
    }))
    .pipe(rename({
      suffix: '.min'
    }))
    .pipe(minifycss())
    .pipe(gulp.dest('./../static/css'));
});

gulp.task("webpack", ['uiBuildJs'], function(callback) {
  var config = require('./webpack.config.js');
  // run webpack
  webpack(config, function(err, stats) {
    if (err) throw new gutil.PluginError("webpack", err);
    gutil.log("[webpack]", stats.toString({
      // output options
    }));
    callback();
  });
});

gulp.task('default', ['css', 'webpack']);