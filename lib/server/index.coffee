express = require 'express'
app = express()

app.get '/', (req, res)->
  res.send 'hello world'

unless module.parent?
  app.listen 3000

module.exports = app