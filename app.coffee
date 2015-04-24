require 'coffee-script/register'

global.localRequire = (name) ->
  return require(__dirname + '/' + name)

express = require 'express'
config = require './config/config'
glob = require 'glob'
mongoose = require 'mongoose'
chalk = require 'chalk'

mongoose.connect config.db
db = mongoose.connection
db.on 'error', ->
  console.log(
    chalk.red('[DB Error]: ') +
    chalk.dim('Unable to connect to database at ' + config.db)
  )
  return

models = glob.sync(config.root + '/app/models/**/*.coffee')
models.forEach (model) ->
  require model
  return

app = express()

DynamoDB = localRequire 'app/helpers/aws/dynamodb.coffee'
SNS = (localRequire 'app/helpers/aws/sns')('logging',
  'http://26c960f9.ngrok.com/api/v1/logging', 'http')
SQS = (localRequire 'app/helpers/aws/sqs')('logging')

require('./config/express') app, config
app.listen config.port, () ->
  localRequire('app/helpers/utils/document')(app._router.stack)
  DynamoDB.init(app._router.stack)
  # DynamoDB.seed(app._router.stack)
