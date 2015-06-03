mongoose = require 'mongoose'

BaseService = localRequire 'app/services/_base/'
Customer = mongoose.model 'Customer'
Address = mongoose.model 'Address'

options = localRequire 'app/services/_base/options'

class CustomerService extends BaseService

module.exports =
  new CustomerService(
    Customer,
    [Address],
    options)
