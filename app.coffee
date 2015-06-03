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

SNS = (localRequire 'app/helpers/aws/sns')(config.aws.sns)
SQS = (localRequire 'app/helpers/aws/sqs')(config.aws.sqs)

require('./config/express') app, config
app.listen config.port, () ->
  localRequire('app/helpers/utils/routes')(app._router.stack)
