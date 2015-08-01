var gulp = require('gulp');
var elm  = require('gulp-elm');

// elm build
gulp.task('elm-init', elm.init);
gulp.task('elm', ['elm-init'], function(){
  return gulp.src('src/*.elm')
    .pipe(elm())
    .pipe(gulp.dest('build/'))
});

// watch for changes
gulp.task('watch', function() {
  gulp.watch('src/*.elm', ['elm']);
});

gulp.task('default', ['elm', 'watch']);
