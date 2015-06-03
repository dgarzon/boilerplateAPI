module.exports = (routes) ->
  Table = require('cli-table')
  table = new Table(head: [
    ''
    'Name'
    'Path'
  ])
  routes.forEach (item) ->
    if item.name == 'router'
      item.handle.stack.forEach (handler) ->
        if handler.route
          route = handler.route
          entry = {}
          entry[route.stack[0].method.toUpperCase()] = [
            route.path
            route.path
          ]
          table.push entry
        return
    return

  console.log table.toString()
  table
