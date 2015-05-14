'use strict'

express  = require 'express'
router = express.Router()
paginate = require 'express-paginate'

base = '/api/v1/staff'
service = localRequire 'app/services/business/store'
controller = (localRequire 'app/controllers/_base/')(service)

logging = localRequire 'app/middlewares/logging/'

module.exports = (app) ->
  app.use router

router.get base + '/', controller.list
router.get base + '/:id', controller.get
router.post base + '/', controller.create
router.put base + '/', controller.update
router.delete base + '/:id', controller.delete

router.get base + '/:id/address', controller.listSub('address')
router.get base + '/:id/address/:subId', controller.getSub('address')
router.post base + '/:id/address', controller.createSub('address')
router.put base + '/:id/address', controller.updateSub('address')
router.delete base + '/:id/address/:subId', controller.deleteSub('address')

router.get base + '/:id/staff', controller.listSub('staff')
router.get base + '/:id/staff/:subId', controller.getSub('staff')
router.post base + '/:id/staff', controller.createSub('staff')
router.put base + '/:id/staff', controller.updateSub('staff')
router.delete base + '/:id/staff/:subId', controller.deleteSub('staff')
