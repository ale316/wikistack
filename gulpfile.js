var gulp = require('gulp');

var gutil = require('gulp-util');

var sass = require('gulp-sass');
var coffeelint = require('gulp-coffeelint');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var handlebars = require('gulp-handlebars');
var wrap = require('gulp-wrap');
var declare = require('gulp-declare');

var sources = {
  app: 'src/*',
  sass: 'sass/**.scss',
  coffee: 'src/**/*.coffee',
  html: 'wikistack.html',
  templates: 'templates/*.hbs',
  libs: ['src/libs/jquery/dist/jquery.js',
         'src/libs/handlebars/handlebars.js']
};

var destinations = {
  css: 'dist/css',
  js: 'dist/js',
  html: 'dist/'
}

gulp.task('style', function() {
  gulp.src(sources.sass)
  .pipe(sass({outputStyle: 'compressed', errLogToConsole: true}))
  .pipe(concat('wikistack.css'))
  .pipe(gulp.dest(destinations.css));
});

gulp.task('html', function() {
  gulp.src(sources.html)
  .pipe(gulp.dest(destinations.html));
});

gulp.task('lint', function() {
  gulp.src(sources.coffee)
  .pipe(coffeelint({"max_line_length": {"level": "ignore"}}))
  .pipe(coffeelint.reporter());
});

gulp.task('libs', function() {
  gulp.src(sources.libs)
  .pipe(concat('wikistack-libs.js'))
  .pipe(uglify())
  .pipe(gulp.dest(destinations.js));
});

gulp.task('templates', function () {
  gulp.src(sources.templates)
  .pipe(handlebars())
  .pipe(wrap('Handlebars.template(<%= contents %>)'))
  .pipe(declare({
      namespace: 'WikiStack.templates',
      noRedeclare: true // Avoid duplicate declarations
  }))
  .pipe(concat('wikistack-templates.js'))
  .pipe(gulp.dest(destinations.js));
});

gulp.task('src', function() {
  gulp.src(sources.coffee)
  .pipe(coffee({bare: true}).on('error', gutil.log))
  .pipe(concat('wikistack.js'))
  .pipe(uglify())
  .pipe(gulp.dest(destinations.js));
});

gulp.task('watch', function() {
  gulp.watch(sources.sass, ['style']);
  gulp.watch(sources.templates, ['templates']);
  gulp.watch(sources.app, ['lint', 'libs', 'src', 'html']);
  gulp.watch(sources.html, ['html']);
});

gulp.task('default', ['style', 'lint', 'libs', 'templates', 'src', 'html', 'watch']);