AWS = localRequire 'app/helpers/aws'
async = require 'async'
chalk = require 'chalk'

class SNS

  constructor: (@name, @endpoint, @protocol) ->
    @notifier = new AWS.SNS(
      apiVersion: '2010-03-31'
    )
    @params =
      TopicArn: ''
      Protocol: @protocol
      Endpoint: @endpoint
    @confirmed = false

  startProcess = () ->
    (next) ->
      next(null)

  create = (callback) ->
    _this = @

    params =
      Name: @name

    @notifier.createTopic params, (err, data) ->
      if err
        console.log(
          chalk.red('[SNS Error]: ') +
          chalk.dim('Failed to create new ' + _this.name + ' topic')
        )
        callback(err)
        return
      else
        _this.params.TopicArn = data.TopicArn
        console.log(
          chalk.green('[SNS Success]: ') +
          chalk.dim('Created new ' + _this.name + ' topic')
        )
        callback(null)
        return

  subscribe = (callback) ->
    params = @params

    @notifier.subscribe params, (err, data) ->
      if err
        console.log(
          chalk.red('[SNS Error]: ') +
          chalk.dim('Failed to subscribe to new topic')
        )
        callback(err)
        return
      else
        console.log(
          chalk.green('[SNS Success]: ') +
          chalk.dim('Subscribed to new topic')
        )
        callback(null)
        return

  init: () ->
    async.waterfall [
      startProcess()
      create.bind(@)
      subscribe.bind(@)
    ], (err) ->
      return

  confirm: (token, callback) ->
    _confirmed = @confirmed

    params =
      Token: token
      TopicArn: @params.TopicArn

    @notifier.confirmSubscription params, (err, data) ->
      if err
        console.log(
          chalk.red('[SNS Error]: ') +
          chalk.dim('Failed to confirm subscription to topic')
        )
        callback(err)
        return
      else
        console.log(
          chalk.green('[SNS Success]: ') +
          chalk.dim('Confirmed subscription to topic')
        )
        _confirmed = true
        callback(null, data)
        return

  publish: (message) ->

module.exports = (topic, endpoint, protocol) ->
  new SNS(topic, endpoint, protocol)
