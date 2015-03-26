express  = require 'express'
router = express.Router()
mongoose = require 'mongoose'

module.exports = (app) ->
  app.use '/', router

router.get '/', (req, res, next) ->
  res.status = 200
  res.send
    data:
      message: 'Working..'
