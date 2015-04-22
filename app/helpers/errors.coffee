'use strict'

class Errors

  constructor: () ->

  resourceNotFound: (modelName) ->
    err = new Error '[Error]: ' + modelName + \
                   ' resource not found.'
    err.status = 404
    return err

  invalidJSON: () ->
    err = new Error '[Error]: Received an invalid JSON object.'
    err.status = 500
    return err

  invalidQuery: () ->
    err = new Error '[Error]: Received an invalid query.'
    err.status = 500
    return err


module.exports = new Errors()
