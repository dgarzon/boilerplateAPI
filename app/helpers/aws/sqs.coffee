AWS = localRequire 'app/helpers/aws'
Q = require 'q'
chalk = require 'chalk'
errors = localRequire 'app/helpers/errors'

class SQS

  getMessage = Q.nbind(@queue.queue.receiveMessage, @queue.queue)
  deleteMessage = Q.nbind(@queue.queue.deleteMessage, @queue.queue)

  constructor: (params) ->
    @queue =
      queue: new AWS.SQS(params)
      url: params.url
      params: params

  send: (message, callback) ->
    params =
      QueueUrl: @queue.url
      MessageBody: message

    @queue.queue.sendMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data)
        return


  get: (callback) ->
    @queue.queue.receiveMessage @queue.params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data)
        return

  delete: (handle, callback) ->
    params =
      QueueUrl: @queue.url
      ReceiptHandle: handle

    @queue.queue.deleteMessage params, (err, data) ->
      if err
        callback(err)
        return
      else
        callback(err, data)
        return

  poll: () ->
    getMessage()
      .then (data) ->
        if not data.Messages
          throw workflowError 'QueueEmpty', new Error('Queue is empty')

        console.log(
          chalk.green('[SQS Message]: ') +
          chalk.dim('Received message from queue')
        )
        body = JSON.parse(data.Messages[0].Body)

        console.log(
          chalk.magenta('[SQS Message]: ') +
          chalk.dim(body)
        )

        deleteMessage
          ReceiptHandle: data.Messages[0].ReceiptHandle
        return
      .then (data) ->
        console.log(
          chalk.yellow('[SQS Message]: ') +
          chalk.dim('Deleted last message from queue')
        )
      .catch (err) ->
        switch err.type
          when 'QueueEmpty'
            console.log(
              chalk.red('[SQS Error]: ') +
              chalk.dim(err.message)
            )
          else
            console.log(
              chalk.red('[SQS Error]: ') +
              chalk.dim(err)
            )
      .finally poll
      return

module.exports = (params) ->
  new SQS(params)
