'use strict'

express  = require 'express'
router = express.Router()
paginate = require 'express-paginate'

base = '/api/v1/customers'
service = localRequire 'app/services/_groups/customer'
controller = (localRequire 'app/controllers/_base/')(service)

logging = localRequire 'app/middlewares/logging/'

module.exports = (app) ->
  app.use router

router.get base + '/', controller.list
router.get base + '/:id', controller.get
router.post base + '/', controller.create
router.put base + '/', controller.update
router.delete base + '/:id', controller.delete

router.get base + '/:id/addresses', controller.listSub('address')
router.get base + '/:id/addresses/:subId', controller.getSub('address')
router.post base + '/:id/addresses', controller.createSub('address')
router.put base + '/:id/addresses', controller.updateSub('address')
router.delete base + '/:id/addresses/:subId', controller.deleteSub('address')
