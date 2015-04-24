'use strict'

util = require 'util'
mongoose = require 'mongoose'
Schema   = mongoose.Schema

BaseSchema = ->
  Schema.apply this, arguments

  this.virtual('name.full').get ->
    @name.first + ' ' + @name.last

  this.pre 'save', (next) ->
    now = new Date()
    @updatedAt = now.toISOString()
    if !@createdAt
      @createdAt = now.toISOString()
    next()
    return

  this.methods.toJSON = ->
    obj = @.toObject()
    obj.id = obj._id

    delete obj.password
    delete obj._id
    delete obj.__t
    delete obj.__v

    obj.createdAt = obj.createdAt.toDateString()
    obj.updatedAt = obj.updatedAt.toDateString()

    return obj

  this.set 'toJSON', virtuals: true

  @add
    name:
      first:
        type: String
        required: true
      last:
        type: String
        required: true

    addresses: [
      type: Schema.ObjectId
      ref: 'Address'
    ]
    email:
      type: String
      required: true

    username:
      type: String
      # required: true
    password:
      type: String
      # required: true
    role:
      type: String
      # required: true

    active:
      type: Boolean
      default: true

    createdAt:
      type: Date
    updatedAt:
      type: Date
  return



util.inherits BaseSchema, Schema
module.exports = BaseSchema
