mongoose = require 'mongoose'

BaseService = localRequire 'app/services/_base/'
Staff = mongoose.model 'Staff'
Address = mongoose.model 'Address'
Payment = mongoose.model 'Payment'
Rental = mongoose.model 'Rental'

class StaffService extends BaseService

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
  new StaffService(
    Staff,
    [Address, Payment, Rental],
    options)
