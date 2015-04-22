'use strict'

class Utils

  constructor: () ->

  getFunctionName: (fun) ->
    ret = fun.toString()
    ret = ret.substr('function '.length)
    ret = ret.substr(0, ret.indexOf('('))
    return ret

module.exports = new Utils()
