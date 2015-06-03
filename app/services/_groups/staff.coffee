mongoose = require 'mongoose'

BaseService = localRequire 'app/services/_base/'
Staff = mongoose.model 'Staff'
Address = mongoose.model 'Address'

options = localRequire 'app/services/_base/options'

class StaffService extends BaseService

module.exports =
  new StaffService(
    Staff,
    [Address],
    options)
