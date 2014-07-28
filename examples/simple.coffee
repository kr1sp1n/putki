es = require 'event-stream'
inspect = require('util').inspect
http = require 'http'

list = []

api = 
  '':
    get: (req, res)->
      return es.map (data, next)->
        console.log 'ROOT'
        next null, data

  list:
    get: (req, res)->
      console.log 'GET list'
      return es.map (data, next)->
        next null, list
  pipe:
    get: (req, res)->
      return es.map (data, next)->
        next null, "hallo"
        
    put: (req, res)->
      return es.map (data, next)->
        list.push data
        next null, data

dispatcher = (req, res)->
  method = req.method.toLowerCase()
  resource = req.url.split('/')[1]
  return api[resource][method](req, res)

toJson = (req, res)->
  return es.map (data, done)->
    result =
      success: true
      items: list
    done null, result


server = http.createServer (req, res)->

  req
    .pipe es.split()
    .pipe dispatcher req, res
    .pipe es.wait (err, text)->
      console.error err if err
    .pipe toJson()
    .pipe es.stringify()
    .pipe res


unless module.parent

  server.listen 3002

  # process.stdin
  #   .pipe es.split()
  #   .pipe es.parse()
  #   .pipe es.map (data, done)->
  #     console.log data
  #     done null, data
  #   .pipe process.stdout