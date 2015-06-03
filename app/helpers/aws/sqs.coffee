AWS = localRequire 'app/helpers/aws'
Q = require 'q'
chalk = require 'chalk'
errors = localRequire 'app/helpers/utils/errors'

class SQS
  @_instance = null

  constructor: (@options) ->
    @name = @options.name
    
    @queue = new AWS.SQS(
      apiVersion: '2012-11-05'
    )
    @information =
      QueueUrl: ''

    @getMessage = Q.nbind(@queue.receiveMessage, @queue)
    @deleteMessage = Q.nbind(@queue.deleteMessage, @queue)

  @get: (name) ->
    if not @_instance?
      @_instance = new @(name)
      @_instance.create()
    @_instance

  create: () ->
    _this = @

    params =
      QueueName: _this.name

    @queue.createQueue params, (err, data) ->
      if err
        console.log(
          chalk.red('[SQS]: ') +
          chalk.dim('Failed to create new ' + _this.name + ' queue.')
        )
        return
      else
        _this.information.QueueUrl = data.QueueUrl
        console.log(
          chalk.yellow('[SQS]: ') +
          chalk.dim('Created new ' + _this.name + ' queue.')
        )
        return

  send: (message, callback) ->
    params =
      QueueUrl: @information.QueueUrl
      MessageBody: message

    @queue.sendMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data)
        return

  get: (callback) ->
    params =
      QueueUrl: @information.QueueUrl

    @queue.receiveMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data.Messages[0])
        return

  delete: (handle, callback) ->
    params =
      QueueUrl: @information.QueueUrl
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

module.exports = (name=null) ->
  SQS.get(name)
