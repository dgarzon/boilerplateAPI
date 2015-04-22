class Logging

  constructor: () ->
    @SQS = (localRequire 'app/helpers/aws/sqs')('logging')
    @SQS.create()

    @SNS = (localRequire 'app/helpers/aws/sns')('logging',
      'http://1a60cd5.ngrok.com/api/v1/logging', 'http')
    @SNS.init()

  before: () ->

  after: () ->


module.exports =
  new Logging()
