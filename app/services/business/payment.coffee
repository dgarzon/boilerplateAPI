mongoose = require 'mongoose'

BaseService = localRequire 'app/services/_base/'
Payment = mongoose.model 'Payment'

class PaymentService extends BaseService

options = {
  query:
    accept: ['String', 'Number', 'Boolean']
    skip: ['__v', '_id', '__t', 'password']
  pagination:
    defaults:
      limit: 10
      offset: 0
  relationships:
    pagination:
      defaults:
        limit: 10
        offset: 0
}

module.exports =
  new PaymentService(Payment, [], options)
