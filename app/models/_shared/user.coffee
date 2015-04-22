'use strict'

mongoose = require('mongoose')

BaseSchema = localRequire 'app/models/_base/'
UserSchema = new BaseSchema

mongoose.model 'User', UserSchema
