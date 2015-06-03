options =
  query:
    accept: ['String', 'Number', 'Boolean', 'Date']
    skip: ['__v', '_id', '__t', 'password']
  pagination:
    defaults:
      limit: 10
      offset: 0
  relationships:
    pagination:
      defaults:
        limit: 10
        offset: 0

module.exports = options
