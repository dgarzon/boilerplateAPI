'use strict'

mongoose = require('mongoose')
Schema = mongoose.Schema

RentalSchema = new Schema(
  staff:
    type: Schema.ObjectId
    ref: 'Staff'
  customer:
    type: Schema.ObjectId
    ref: 'Customer'
  rentalDate:
    type: Date
    default: Date.now()
  returnDate:
    type: Date
    default: Date.now() + 7.0
  createdAt:
    type: Date
    default: Date.now()
  updatedAt:
    type: Date
)

RentalSchema.set 'toJSON', virtuals: true

mongoose.model 'Rental', RentalSchema
module.exports = RentalSchema
