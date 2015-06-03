'use strict'

mongoose = require 'mongoose'
Schema   = mongoose.Schema

PersonSchema = localRequire 'app/models/_person/'
AdminSchema = new PersonSchema()

User  = mongoose.model 'User'
Admin = User.discriminator 'Admin', AdminSchema
