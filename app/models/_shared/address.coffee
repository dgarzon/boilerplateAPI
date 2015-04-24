'use strict'

mongoose = require('mongoose')
Schema = mongoose.Schema

AddressSchema = new Schema(
  staff:
    type: Schema.ObjectId
    ref: 'Staff'
  firstLine:
    type: String
  secondLine:
    type: String
  city:
    type: String
  state:
    type: String
  zipCode:
    type: String
  country:
    type: String

  createdAt:
    type: Date
    default: Date.now()
  updatedAt:
    type: Date
)

AddressSchema.set 'toJSON', virtuals: true

AddressSchema.pre 'save', (next) ->
  now = new Date
  @updatedAt = now
  if !@createdAt
    @createdAt = now
  next()
  return

AddressSchema.post 'save', () ->
  @model('Staff').findByIdAndUpdate @staff, { $push: addresses: @_id }, {
    safe: true
    upsert: true
  }, (err, model) ->
    if err
      console.log err

AddressSchema.pre 'remove', (next) ->
  @model('Staff').findByIdAndUpdate @staff, { $pull: addresses: @_id }, {
    safe: true
    upsert: true
  }, (err, model) ->
    if err
      console.log err
    next()

mongoose.model 'Address', AddressSchema
