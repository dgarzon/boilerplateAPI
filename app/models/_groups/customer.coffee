'use strict'

mongoose = require 'mongoose'
Schema   = mongoose.Schema

PersonSchema = localRequire 'app/models/_person/'
CustomerSchema = new PersonSchema()

User  = mongoose.model 'User'
Customer = User.discriminator 'Customer', CustomerSchema
