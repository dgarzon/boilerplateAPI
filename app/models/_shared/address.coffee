'use strict'

mongoose = require('mongoose')
Schema = mongoose.Schema

AddressSchema = new Schema(
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

mongoose.model 'Address', AddressSchema
