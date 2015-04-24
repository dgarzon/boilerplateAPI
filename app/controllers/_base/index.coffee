'use strict'

express  = require 'express'

class BaseController
  constructor: (@service) ->

  send = (req, res, next) ->
    return res.status(res.statusCode)
              .send(
                res.data
              )

  list: (req, res, next) =>
    @service.list req, (err, resources) ->
      return next(err) if err
      res.statusCode = 200
      res.data = resources
      send(req, res, next)
      # return next()

  get: (req, res, next) =>
    @service.get req, (err, resource) ->
      return next(err) if err
      res.statusCode = 200
      res.data = resource
      send(req, res, next)
      # return next()

  create: (req, res, next) =>
    @service.create req, (err, resource) ->
      return next(err) if err
      res.statusCode = 201
      res.data = resource
      send(req, res, next)
      # return next()

  update: (req, res, next) =>
    @service.update req, (err, resource) ->
      return next(err) if err
      res.statusCode = 200
      res.data = resource
      send(req, res, next)
      # return next()

  delete: (req, res, next) =>
    @service.delete req, (err, success) ->
      return next(err) if err
      res.statusCode = 200
      res.data = success
      send(req, res, next)
      # return next()

  listSub: (name) =>
    (req, res, next) =>
      @service.listSub req, name, (err, resources) ->
        return next(err) if err
        res.statusCode = 200
        res.data = resources
        send(req, res, next)
        # return next()

  getSub: (name) =>
    (req, res, next) =>
      @service.getSub req, name, (err, resource) ->
        return next(err) if err
        res.statusCode = 200
        res.data = resource
        send(req, res, next)
        # return next()

  createSub: (name) =>
    (req, res, next) =>
      @service.createSub req, name, (err, resource) ->
        return next(err) if err
        res.statusCode = 201
        res.data = resource
        send(req, res, next)

  updateSub: (name) =>
    (req, res, next) =>
      @service.updateSub req, (err, resource) ->
        return next(err) if err
        res.statusCode = 200
        res.data = resource
        send(req, res, next)
        # return next()

  deleteSub: (name) =>
    (req, res, next) =>
      @service.deleteSub req, name, (err, data) ->
        return next(err) if err
        res.statusCode = 200
        res.data = data
        send(req, res, next)
        # return next()

module.exports = (service) ->
  new BaseController(service)
