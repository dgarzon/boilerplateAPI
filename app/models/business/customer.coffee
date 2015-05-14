'use strict'

mongoose = require 'mongoose'
Schema   = mongoose.Schema

BaseSchema = localRequire 'app/models/_base/'

CustomerSchema = new BaseSchema(
  role:
    type: String
    default: 'customer'
)

User  = mongoose.model 'User'
Customer = User.discriminator 'Customer', CustomerSchema
