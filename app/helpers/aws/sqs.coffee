AWS = localRequire 'app/helpers/aws'
Q = require 'q'
chalk = require 'chalk'
errors = localRequire 'app/helpers/utils/errors'

class SQS
  @_instance = null

  constructor: (@options) ->
    @queue = new AWS.SQS(
      apiVersion: '2012-11-05'
    )

    @getMessage = Q.nbind(@queue.receiveMessage, @queue)
    @deleteMessage = Q.nbind(@queue.deleteMessage, @queue)

  @get: (options) ->
    if not @_instance?
      @_instance = new @(options)
      @_instance.create()
    @_instance

  create: () ->
    _this = @

    params =
      QueueName: _this.options.name

    @queue.createQueue params, (err, data) ->
      if err
        console.log(
          chalk.red('[SQS]: ') +
          chalk.dim('Failed to create new ' + _this.options.name + ' queue.')
        )
        return
      else
        _this.options.url = data.QueueUrl
        console.log(
          chalk.yellow('[SQS]: ') +
          chalk.dim('Created new ' + _this.options.name + ' queue.')
        )
        return

  send: (message, callback) ->
    params =
      QueueUrl: @options.url
      MessageBody: message

    @queue.sendMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data)
        return

  get: (callback) ->
    _this = @

    params =
      QueueUrl: @options.url

    @queue.receiveMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        message = data.Messages[0]
        callback(err, message)
        return

  delete: (handle, callback) ->
    params =
      QueueUrl: @options.url
      ReceiptHandle: handle

    @queue.deleteMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data)
        return

  poll: () ->
    _this = @
    _this.getMessage()
      .then (data) ->
        if not data.Messages
          throw workflowError 'QueueEmpty', new Error('Queue is empty')

        console.log(
          chalk.yellow('[SQS]: ') +
          chalk.dim('Received message from queue.')
        )
        body = JSON.parse(data.Messages[0].Body)

        console.log(
          chalk.yellow('[SQS]: ') +
          chalk.dim(body)
        )

        _this.deleteMessage
          ReceiptHandle: data.Messages[0].ReceiptHandle
        return
      .then (data) ->
        console.log(
          chalk.yellow('[SQS]: ') +
          chalk.dim('Deleted last message from queue')
        )
      .catch (err) ->
        switch err.type
          when 'QueueEmpty'
            console.log(
              chalk.red('[SQS]: ') +
              chalk.dim(err.message)
            )
          else
            console.log(
              chalk.red('[SQS]: ') +
              chalk.dim(err)
            )
      .finally poll
      return

module.exports = (options=null) ->
  SQS.get(options)
