# lib/streams/server.coffee
http = require 'http'
concat = require 'concat-stream'
from = require 'from'
through = require 'through'

stream = require 'stream'
Transform = stream.Transform

server = http.createServer (req, res)->
  req.pipe(concat (body)->
    console.log body
    res.end "hello\n"
  )

server.listen 3002
