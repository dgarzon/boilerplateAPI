express = require 'express'
glob = require 'glob'

logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
compress = require 'compression'
methodOverride = require 'method-override'

module.exports = (app, config) ->
  env = process.env.NODE_ENV || 'development'
  app.locals.ENV = env
  app.locals.ENV_DEVELOPMENT = env == 'development'

  app.use logger 'dev'
  app.use bodyParser.json()
  app.use bodyParser.urlencoded(
    extended: true
  )
  app.use cookieParser()
  app.use compress()
  app.use express.static config.root + '/app/public'
  app.use methodOverride()

  controllers = glob.sync config.root + '/app/controllers/**/*.coffee'
  controllers.shift()
  
  controllers.forEach (controller) ->
    require(controller)(app)

  app.use (req, res, next) ->
    err = new Error 'Not Found'
    err.status = 404
    next err

  if app.get('env') == 'development'
    app.use (err, req, res, next) ->
      res.status err.status || 500
      res.send
        message: err.message
        error: err

  app.use (err, req, res, next) ->
    res.status err.status || 500
    res.send
      message: err.message
      error: {}
