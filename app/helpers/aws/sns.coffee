AWS = localRequire 'app/helpers/aws'

class SNS

  constructor: (params) ->
    notifier = new AWS.SNS(
      params
    )
