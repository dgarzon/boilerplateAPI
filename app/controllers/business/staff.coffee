'use strict'

express  = require 'express'
router = express.Router()
paginate = require 'express-paginate'

baseUrl = '/api/v1/staff'
service = localRequire 'app/services/business/staff'
controller = (localRequire 'app/controllers/_base/')(service)

logging = localRequire 'app/middlewares/logging/'

module.exports = (app) ->
  app.use baseUrl, router

router.get '/', controller.query
router.get '/:id', controller.detail
router.post '/', controller.create
router.put '/', controller.update
router.delete '/:id', controller.delete
