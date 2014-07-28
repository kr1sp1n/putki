
moment = require 'moment'
Schema = require('jugglingdb').Schema

module.exports = (uri)->
  config = {}
  type = uri if uri == 'memory'
  db = new Schema type, config

  db.define 'Pipe',
    title:
      type: String
      length: 255

  return db