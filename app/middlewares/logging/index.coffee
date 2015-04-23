class Logging

  constructor: () ->
    @SQS = (localRequire 'app/helpers/aws/sqs')('logging')
    @SQS.create()

    @SNS = (localRequire 'app/helpers/aws/sns')('logging',
      'http://1a60cd5.ngrok.com/api/v1/logging', 'http')
    @SNS.init()

  before: (req, res, next) ->

  after: (req, res, next) ->

module.exports =
  new Logging()
