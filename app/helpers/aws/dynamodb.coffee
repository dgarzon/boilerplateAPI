AWS = localRequire 'app/helpers/aws'
vogels = require 'vogels'
Joi = require 'joi'

async = require 'async'
chalk = require 'chalk'

driver = new AWS.DynamoDB()
vogels.dynamoDriver(driver)

Authorization = vogels.define('Authorization',
  hashKey: 'endpoint'
  timestamps: true
  schema:
    endpoint: Joi.string()
    method: Joi.string()
    groups: vogels.types.stringSet()
  )

class DynamoDB

  constructor: (args) ->
