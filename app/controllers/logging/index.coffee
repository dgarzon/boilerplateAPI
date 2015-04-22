express  = require 'express'
router = express.Router()

logging = localRequire 'app/middlewares/logging/'

module.exports = (app) ->
  app.use '/api/v1/logging', router

router.post '/', (req, res, next) ->
  if req.body.Type == 'SubscriptionConfirmation' and not logging.confirmed
    logging.SNS.confirm req.body.Token, (err, data) ->
      if err
        next(err)
      else
        res.status(200).send()
  else
    res.status(200).send()
