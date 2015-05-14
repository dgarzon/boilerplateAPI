'use strict'

mongoose = require('mongoose')
Schema = mongoose.Schema

PaymentSchema = new Schema(
  staff:
    type: Schema.ObjectId
    ref: 'Staff'
  customer:
    type: Schema.ObjectId
    ref: 'Customer'
  rental:
    type: Schema.ObjectId
    ref: 'Rental'
  amount:
    type: Number
  createdAt:
    type: Date
    default: Date.now()
  updatedAt:
    type: Date
)

PaymentSchema.set 'toJSON', virtuals: true

mongoose.model 'Payment', PaymentSchema

module.exports = PaymentSchema
