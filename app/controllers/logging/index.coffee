express  = require 'express'
router = express.Router()

base = '/api/v1/logging'
SNS = (localRequire 'app/helpers/aws/sns')()

module.exports = (app) ->
  app.use router

router.post base + '/', (req, res, next) ->
  if req.body.Type == 'SubscriptionConfirmation' and not SNS.confirmed
    SNS.confirm req.body.Token, (err, data) ->
      if err
        next(err)
      else
        res.status(200).send()
  else
    res.status(200).send()
