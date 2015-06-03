'use strict'

mongoose = require 'mongoose'
Schema   = mongoose.Schema

PersonSchema = localRequire 'app/models/_person/'
StaffSchema = new PersonSchema()

User  = mongoose.model 'User'
Staff = User.discriminator 'Staff', StaffSchema
