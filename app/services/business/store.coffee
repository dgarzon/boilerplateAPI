mongoose = require 'mongoose'

BaseService = localRequire 'app/services/_base/'
Store = mongoose.model 'Store'
Staff = mongoose.model 'Staff'
Address = mongoose.model 'Address'

class StoreService extends BaseService

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
  new StoreService(
    Store,
    [Staff, Address],
    options)
