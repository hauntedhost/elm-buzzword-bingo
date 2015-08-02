var gulp = require('gulp');
var gutil = require('gulp-util');
var plumber = require('gulp-plumber');
var elm  = require('gulp-elm');

// build error handler
var onError = function(error) {
  gutil.beep();
  gutil.log(error.toString());
};

// elm build
gulp.task('elm-init', elm.init);
gulp.task('elm', ['elm-init'], function() {
  return gulp.src('src/Bingo.elm')
    .pipe(plumber({
      errorHandler: onError
    }))
    .pipe(elm())
    .pipe(gulp.dest('build/'))
});

// watch for changes
gulp.task('watch', function() {
  gulp.watch('src/*.elm', ['elm']);
});

gulp.task('default', ['elm', 'watch']);
