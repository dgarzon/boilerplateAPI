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

  test:
    root: rootPath
    app:
      name: 'test'
    port: 3000
    db: 'mongodb://localhost/api-test'

  production:
    root: rootPath
    app:
      name: 'test'
    port: 3000
    db: 'mongodb://localhost/api-production'

module.exports = config[env]
