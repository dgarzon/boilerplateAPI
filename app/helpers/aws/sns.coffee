AWS = localRequire 'app/helpers/aws'
async = require 'async'
chalk = require 'chalk'

class SNS
  @_instance = null

  constructor: (@options) ->
    @notifier = new AWS.SNS(
      apiVersion: '2010-03-31'
    )
    @params =
      TopicArn: ''
      Protocol: @options.protocol
      Endpoint: @options.endpoint
    @confirmed = false

  @get: (options) ->
    if not @_instance?
      @_instance = new @(options)
      @_instance.init()
    @_instance

  startProcess = () ->
    (next) ->
      next(null)

  create = (callback) ->
    _this = @

    params =
      Name: @options.name

    @notifier.createTopic params, (err, data) ->
      if err
        console.log(
          chalk.red('[SNS]: ') +
          chalk.dim('Failed to create new ' + _this.options.name + ' topic.')
        )
        callback(err)
        return
      else
        _this.params.TopicArn = data.TopicArn
        console.log(
          chalk.magenta('[SNS]: ') +
          chalk.dim('Created new ' + _this.options.name + ' topic.')
        )
        callback(null)
        return

  subscribe = (callback) ->
    params = @params

    @notifier.subscribe params, (err, data) ->
      if err
        console.log(
          chalk.red('[SNS]: ') +
          chalk.dim('Failed to subscribe to topic.')
        )
        callback(err)
        return
      else
        console.log(
          chalk.magenta('[SNS]: ') +
          chalk.dim('Subscribed to topic.')
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
          chalk.red('[SNS]: ') +
          chalk.dim('Failed to confirm subscription to topic.')
        )
        callback(err)
        return
      else
        console.log(
          chalk.magenta('[SNS]: ') +
          chalk.dim('Confirmed subscription to topic.')
        )
        _confirmed = true
        callback(null, data)
        return

  publish: (message) ->

module.exports = (options=null) ->
  SNS.get(options)
