path     = require 'path'
rootPath = path.normalize __dirname + '/..'
env      = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app:
      name: 'test'
    port: 3000
    db: 'mongodb://localhost/api-development'
    aws:
      sns:
        name: 'logging'
        endpoint: 'http://2672539b.ngrok.io/api/v1/logging'
        protocol: 'http'
      sqs:
        name: 'logging'
        url: ''

  test:
    root: rootPath
    app:
      name: 'test'
    port: 3000
    db: 'mongodb://localhost/api-test'
    aws:
      sns:
        name: 'logging'
        endpoint: 'http://2672539b.ngrok.io/api/v1/logging'
        protocol: 'http'
      sqs:
        name: 'logging'
        url: ''

  production:
    root: rootPath
    app:
      name: 'test'
    port: 3000
    db: 'mongodb://localhost/api-production'
    aws:
      sns:
        name: 'logging'
        endpoint: 'http://2672539b.ngrok.io/api/v1/logging'
        protocol: 'http'
      sqs:
        name: 'logging'
        url: ''

module.exports = config[env]
