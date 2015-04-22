module.exports = ->
  AWS = require 'aws-sdk'
  AWS.config.update
    region: 'us-east-1'
