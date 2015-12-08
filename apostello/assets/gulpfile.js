var gulp = require('gulp'),
  plumber = require('gulp-plumber'),
  rename = require('gulp-rename');
var autoprefixer = require('gulp-autoprefixer');
var babel = require('gulp-babel');
var eslint = require('gulp-eslint');
var uglify = require('gulp-uglify');
var minifycss = require('gulp-minify-css');
var sass = require('gulp-sass');
var bower = require('gulp-bower');
var notify = require('gulp-notify');
var concat = require('gulp-concat');

var config = {
  jsPath: './js',
  sassPath: './css',
  bowerDir: './bower_components'
}

gulp.task('bowerInstall', function() {
  return bower()
    .pipe(gulp.dest(config.bowerDir))
});

gulp.task('bowerCopyImages', function() {
  return gulp.src([
      config.bowerDir + '/select2/*.png',
      config.bowerDir + '/select2/*.gif',
    ])
    .pipe(gulp.dest('./dist/css'));
});

gulp.task('css', function() {
  gulp.src([
      './css/**/*.scss',
      config.bowerDir + '/select2/*.css',
      // config.bowerDir + '/select2-bootstrap-css/*min.css',
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
        config.sassPath,
        config.bowerDir + '/bootstrap/scss',
      ]
    }))
    .pipe(rename({
      suffix: '.min'
    }))
    .pipe(minifycss())
    // .pipe(gulp.dest('./dist/css/'))
    .pipe(concat({
      path: 'apostello.min.css',
    }))
    .pipe(gulp.dest('./dist/css'));
});

gulp.task('js', function() {
  return gulp.src([
      config.bowerDir + '/jquery/dist/jquery.js',
      config.bowerDir + '/bootstrap/dist/js/bootstrap.js',
      config.bowerDir + '/select2/select2.js',
      config.bowerDir + '/react/react.js',
      config.bowerDir + '/react/react-dom.js',
      './js/*.js',
    ])
    .pipe(plumber({
      errorHandler: function(error) {
        console.log(error.message);
        this.emit('end');
      }
    }))
    .pipe(uglify())
    .pipe(concat({
      path: 'apostello.min.js',
    }))
    .pipe(gulp.dest('./dist/js'));
});

gulp.task('jsx', function() {
  return gulp.src([
      './js/**/*.jsx',
    ])
    .pipe(plumber({
      errorHandler: function(error) {
        console.log(error.message);
        this.emit('end');
      }
    }))
    .pipe(babel({
      compact: true,
      comments: false,
      presets: ['es2015', 'react']
    }))
    .pipe(uglify())
    .pipe(gulp.dest('./dist/js'));
});

gulp.task('watch', function() {
  gulp.watch("./css/**/*.*", ['css']);
  gulp.watch("./js/**/*.js", ['js']);
  gulp.watch("./js/**/*.jsx", ['jsx']);
});

gulp.task('default', ['bowerCopyImages', 'js', 'jsx', 'css']);