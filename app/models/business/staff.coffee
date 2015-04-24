'use strict'

mongoose = require 'mongoose'
Schema   = mongoose.Schema

BaseSchema = localRequire 'app/models/_base/'

StaffSchema = new BaseSchema(
  role:
    type: String
    default: 'employee'
)

User  = mongoose.model 'User'
Staff = User.discriminator 'Staff', StaffSchema
