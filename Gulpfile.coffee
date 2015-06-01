gulp = require 'gulp'
livereload = require 'gulp-livereload'
nodemon = require 'gulp-nodemon'

gulp.task 'watch', ->

gulp.task 'develop', ->
  livereload.listen()
  nodemon(
    script: 'app.coffee'
    ext: 'coffee').on 'restart', ->
    setTimeout (->
      livereload.changed __dirname
      return
    ), 500
    return
  return

gulp.task 'default', [
  'develop'
  'watch'
]

gulp.task 'test', [
  
]
