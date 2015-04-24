AWS = localRequire 'app/helpers/aws'
vogels = require 'vogels'
Joi = require 'joi'

async = require 'async'
chalk = require 'chalk'

driver = new AWS.DynamoDB()
vogels.dynamoDriver(driver)

Authorization = vogels.define('Authorization',
  hashKey: '_id'
  rangeKey: 'endpoint'
  timestamps: false
  schema:
    _id: vogels.types.uuid()
    endpoint: Joi.string()
    method: Joi.string()
    groups: vogels.types.stringSet()
  indexes : [
    hashKey: 'endpoint'
    type: 'global'
    name: 'EndpointIndex'
  ]
)

Authorization.config(tableName: 'Authorization')

class DynamoDB

  constructor: () ->

  startProcess = (routes) ->
    (next) ->
      next null, routes

  clear = (routes, callback) ->
    Authorization
      .scan()
      .exec((err, data) ->
        data.Items.forEach (item) ->
          Authorization.destroy item.attrs._id, (err) ->
        callback(null, routes)
        return
      )

  seed = (routes, callback) ->
    routes.forEach (item) ->
      if item.name == 'router'
        item.handle.stack.forEach (handler) ->
          if handler.route
            route = handler.route
            entry = new Authorization(
              endpoint: route.path
              method: route.stack[0].method.toUpperCase()
              groups: ['none']
            )
            entry.save (err) ->
          return
      return
    callback(null)
    return

  init: (routes) ->
    async.waterfall [
      startProcess(routes)
      clear
      seed
    ], (err) ->
      if err
        console.log(
          chalk.red('[DynamoDB]: ') +
          chalk.dim('Failed to initialize database.')
        )
      else
        console.log(
          chalk.blue('[DynamoDB]: ') +
          chalk.dim('Initialized database.')
        )

module.exports = exports = new DynamoDB()
