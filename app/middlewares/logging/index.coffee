class Logging

  constructor: () ->
    @SQS = (localRequire 'app/helpers/aws/sqs')()
    @SNS = (localRequire 'app/helpers/aws/sns')()

  before: (req, res, next) ->

  after: (req, res, next) ->

module.exports =
  new Logging()
