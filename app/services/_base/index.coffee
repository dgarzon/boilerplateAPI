'use strict'

_ = require 'lodash'
async = require 'async'
validator = require 'express-validator'
pluralize = require 'pluralize'
url = require 'url'

errors = localRequire 'app/helpers/utils/errors'
utils = localRequire 'app/helpers/utils/'

class BaseService

  constructor: (model, relationships, options) ->
    @base =
      name: model.modelName
      model: model
      fields: filterFields(model, options)
      relationships: createRelationships(relationships, options)
    @options = options

  filterFields = (model, options) ->
    paths = model.schema.paths
    paths =
      _.pick(paths, (item) ->
        type = _.capitalize utils.getFunctionName(item.options.type)
        item.type = type
        return type in options.query.accept and \
          item.path not in options.query.skip
      )

    filtered = {}
    for key, value of paths
      filtered[key] =
        type: value.type

    return filtered

  createRelationships = (relationships, options) ->
    result = []
    for relationship in relationships
      entry = {
        name: relationship.modelName
        model: relationship
        fields: filterFields(relationship, options)
      }
      result.push(entry)

    return result

  startQueryProcess = (model, fields, query, pagination, path) ->
    (next) ->
      next null, model, fields, query, pagination, path

  parseQuery = (model, fields, query, pagination, path, callback) ->
    if query.q
      try
        query.q = JSON.parse(query.q)
      catch error
        callback(erros.invalidJSON())
        return

    callback(null, model, fields, query, pagination, path)
    return

  validateQuery = (model, fields, query, pagination, path, callback) ->
    return callback(null, model, query, pagination, path) if not query.q

    keys =
      query: _.keys query.q
      fields: _.keys fields

    valid = _.every(keys.query, (item) ->
      return _.indexOf(keys.fields, item) >= 0
    )
    return callback(erros.invalidQuery) if not valid

    # TODO: add value validation.

    callback(null, model, query, pagination, path)
    return

  modelQuery = (model, query, pagination, path, callback) ->
    scanner = model
    scanner = scanner.find(query.condition)
    if query.q
      scanner = scanner.where(query.q)
    if query.sort
      scanner = scanner.sort(query.sort)

    callback(null, model, scanner, query, pagination, path)
    return

  processQuery = (model, scanner, query, pagination, path, callback) ->
    counter = Object.create(scanner)

    operations =
      offset: if query.offset then query.offset\
              else pagination.defaults.offset
      limit: if query.limit then query.limit\
              else pagination.defaults.limit
      fields: if query.fields then query.fields else null

    counter.count (err, count) ->
      return callback(err) if err

      if operations.fields
        select = query.fields.split ','
        select = select.join ' '
        scanner = scanner.select(select)

      scanner.skip operations.offset
      scanner.limit operations.limit

      scanner.exec (err, resources) ->
        return callback(err) if err
        callback(null, model, resources, operations, count, path)

  makeLink = (path, limit, offset) ->
    newPath =
      query:
        limit: limit
        offset: offset
    return decodeURIComponent (path.base + url.format(newPath))

  paginateQuery = (model, resources, operations, count, path, callback) ->
    pages = Math.floor(count / operations.limit)
    limit = Number(operations.limit)
    offset = Number(operations.offset)

    links = {}

    links.first =
      rel: 'first'
      href: path.base

    links.self =
      rel: 'self'
      href: makeLink(path, limit, offset)

    if Math.max(0, offset - limit) != 0
      links.prev =
        rel: 'prev'
        href: makeLink(path, limit, Math.max(0, offset - limit))
    else
      links.prev =
        rel: 'prev'
        href: makeLink(path, limit, offset)

    links.next =
      rel: 'next'
      href: makeLink(path, limit, \
                      Math.max(0, \
                      Math.min(limit + offset,
                              Math.floor(pages * limit))))
    links.last =
      rel: 'last'
      href: makeLink(path, limit, \
                     Math.max(0, Math.floor(pages * limit)))

    paginated = resources
    paginated.links = links
    paginated.count = count

    callback(null, model, paginated, path)
    return

  sanitize = (model, result, path, callback) ->
    links = result.links
    count = result.count

    if _.isArray(result)
      cleaned = _.map result, (item) ->
        resource = {}
        resource.data = item.toJSON()
        resource.link =
          rel: 'self'
          href: path.base + '/' + item._id
        return resource
    else
      cleaned = {}
      cleaned.data = result.toJSON()
      cleaned.link =
        rel: 'self'
        href: path.base

    sanitized = {}
    key = pluralize model.modelName.toLowerCase(), _.size(result)
    sanitized[key] = cleaned
    sanitized['links'] = links
    sanitized['count'] = count

    callback(null, sanitized)

  list: (req, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    req.query.condition = {}

    async.waterfall [
      startQueryProcess(@base.model, @base.fields,
                        req.query, @options.pagination, path)
      parseQuery
      validateQuery
      modelQuery
      processQuery
      paginateQuery
      sanitize
    ], callback

  startGetProcess = (model, id, path) ->
    (next) ->
      next(null, model, id, path)

  processGet = (model, id, path, callback) ->
    modelName = model.modelName
    model
      .findById id, (err, resource) ->
        return callback(err) if err
        if !resource
          return callback(errors.resourceNotFound(modelName))

        callback(err, model, resource, path)
        return

  get: (req, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    async.waterfall [
      startGetProcess(@base.model, req.params.id, path)
      processGet
      sanitize
    ], callback

  startCreateProcess = (model, body, path) ->
    (next) ->
      next(null, model, body, path)

  processCreate = (model, body, path, callback) ->
    model
      .create body, (err, resource) ->
        return callback(err) if err
        callback(err, model, resource, path)
        return

  create: (req, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    async.waterfall [
      startCreateProcess(@base.model, req.body, path)
      processCreate
      sanitize
    ], callback

  startUpdateProcess = (model, body, path) ->
    (next) ->
      next(null, model, body, path)

  processUpdate = (model, body, path, callback) ->
    modelName = model.modelName
    model
      .findById body.id, (err, resource) ->
        return callback(err) if err
        if !resource
          return callback(errors.resourceNotFound(modelName))
        updated = _.merge(resource, body)
        updated.save (err) ->
          return callback(err) if err
          callback(err, model, resource, path)
          return

  update: (req, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    async.waterfall [
      startUpdateProcess(@base.model, req.body, path)
      processUpdate
      sanitize
    ], callback

  startDeleteProcess = (model, id) ->
    (next) ->
      next(null, model, id)

  processDelete = (model, id, callback) ->
    modelName = model.modelName
    model
      .findById id, (err, resource) ->
        return callback(err) if err
        if !resource
          return callback(errors.resourceNotFound(modelName))
        resource.remove (err) ->
          return callback(err) if err
          callback(err,
            info:
              message: 'Successfully deleted resource from ' + modelName + '.'
          )
          return

  delete: (req, callback) ->
    async.waterfall [
      startDeleteProcess(@base.model, req.params.id)
      processDelete
    ], callback

  getSubKey = (base, relationship) ->
    modelName = base.model.modelName
    paths = relationship.model.schema.paths
    path =
      _.pick(paths, (item) ->
        type = _.capitalize utils.getFunctionName(item.options.type)
        return type == 'ObjectId' and item.options.ref == modelName
      )

    path = _.keys(path)[0]

    return path

  listSub: (req, name, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    relationship = null
    key = null
    for r in @base.relationships
      if r.name == _.capitalize(name)
        relationship = r
        key = getSubKey(@base, relationship)
        break

    req.query.condition = {}
    req.query['condition'][key] = req.params.id

    async.waterfall [
      startQueryProcess(relationship.model, relationship.fields,
                        req.query, @options.relationships.pagination, path)
      parseQuery
      validateQuery
      modelQuery
      processQuery
      paginateQuery
      sanitize
    ], callback

  getSub: (req, name, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    relationship = null

    for r in @base.relationships
      if r.name == _.capitalize(name)
        relationship = r
        break

    async.waterfall [
      startGetProcess(relationship.model, req.params.subId, path)
      processGet
      sanitize
    ], callback

  createSub: (req, name, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    relationship = null
    key = null
    for r in @base.relationships
      if r.name == _.capitalize(name)
        relationship = r
        key = getSubKey(@base, relationship)
        break

    req.body[key] = req.params.id

    async.waterfall [
      startCreateProcess(relationship.model, req.body, path)
      processCreate
      sanitize
    ], callback

  updateSub: (req, name, callback) ->
    hostName = req.headers.host
    pathName = url.parse(req.originalUrl).pathname

    path =
      base: 'http://' + hostName + pathName

    if path.base.charAt(path.base.length - 1) == '/'
      path.base = path.base.substring(0, path.base.length - 1)

    relationship = null

    for r in @base.relationships
      if r.name == _.capitalize(name)
        relationship = r
        break

    async.waterfall [
      startUpdateProcess(relationship.model, req.body, path)
      processUpdate
      sanitize
    ], callback

  deleteSub: (req, name, callback) ->
    relationship = null

    for r in @base.relationships
      if r.name == _.capitalize(name)
        relationship = r
        break

    async.waterfall [
      startDeleteProcess(relationship.model, req.params.subId)
      processDelete
    ], callback


module.exports = BaseService
