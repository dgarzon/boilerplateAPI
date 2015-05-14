'use strict'

mongoose = require('mongoose')
Schema = mongoose.Schema

StoreSchema = new Schema(
  staff:
    type: Schema.ObjectId
    ref: 'Staff'
  address:
    type: Schema.ObjectId
    ref: 'Address'
  createdAt:
    type: Date
    default: Date.now()
  updatedAt:
    type: Date
)

StoreSchema.set 'toJSON', virtuals: true

mongoose.model 'Store', StoreSchema
module.exports = StoreSchema
