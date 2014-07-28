# lib/streams/server.coffee
http = require 'http'
concat = require 'concat-stream'
from = require 'from'
through = require 'through'

stream = require 'stream'
Transform = stream.Transform

t = through
  write: (data)->
  	console.log data
  end: (x)-> console.log x


server = http.createServer (req, res)->
  req.pipe(concat (body)->
    console.log body.toString()
    res.end body + '\n'
  )

server.listen 3002
