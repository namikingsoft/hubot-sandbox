gulp = require('gulp')
babel = require('gulp-babel')
typescript = require('gulp-typescript')
sourcemaps = require('gulp-sourcemaps')
config = require('../config').js

project = typescript.createProject 'tsconfig.json',
  typescript: require('typescript')

gulp.task 'js', ->
  project.src()
  .pipe sourcemaps.init()
  .pipe typescript project
  .pipe babel()
  .pipe sourcemaps.write()
  .pipe gulp.dest config.dest
