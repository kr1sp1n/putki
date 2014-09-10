es = require 'event-stream'
inspect = require('util').inspect
http = require 'http'
Stream = require('stream').Stream
Immutable = require 'immutable'


lists =
  todo:
    name: 'TODO'
    items: [
      { name: 'Buy milk' }
      { name: 'Plant tree' }
    ]

li = Immutable.Map lists


createList = (done)->
  s = new Stream()
  list_name = false
  s.writable = s.readable = true
  s.write = (data)->
    lists[data.name] = data
    list_name = data.name
    @emit 'data', data
  s.end = ->
    s.emit 'end'
    if list_name 
      done null, lists[list_name]
  return s

getList = (id, done)->
  s = new Stream()
  s.readable = true
  list = lists[id]
  s.emit 'error', new Error "List '#{id}' Not Found" unless list?
  s.end = ->
    s.emit 'data', lists[id] if list?
    s.emit 'end'
    done null, lists[id]
  return s

log = (msg)->
  console.log msg

api = 
  '':
    get: (req, res)->
      return es.map (data, next)->
        log 'ROOT'
        next null, data

  list:
    post: (req, res)->
      return createList (err, result)-> log 'list created...'
      # es.map (item, next)->
      #   lists[item.name] = item
      #   next null, item

    get: (req, res)->
      id = req.url.split('/')[2]
      if id? and id.length > 0
        return getList id, (err, result)-> log 'list delivered...'
      else
        return new Error 'No Id'

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
  f = api[resource][method]
  stream = f req, res
  return stream 

toJson = (req, res)->
  return es.map (data, done)->
    result =
      success: true
      items: []
    done null, result

toMarkdown = (req, res)->
  return es.map (data, done)->
    result = "\n#{data.name}"
    result += '\n===========================\n'
    result += "* #{item.name}\n" for item in data.items
    result += '\n'
    done null, result

trim = /^\s+|\s+$/g

items = []

logger = (req, res)->
  s = new Stream()
  s.writable = s.readable = true

  s.on 'end', (data)->
    @emit 'data', "REQ: #{req.method} #{req.url}\n"

  s.on 'error', (err)->
    log err

  s.end = ->
    s.emit 'end'

  s.write = (d)->
    log d
    @emit 'data', d

  return s



server = http.createServer (req, res)->
  router = dispatcher req, res
  req
    .pipe logger req, res
    .pipe process.stdout

  x = req
    .pipe router 
    #.pipe toJson()
    #.pipe es.stringify()

  x
    .pipe toMarkdown()
    .pipe res
    

    # .pipe es.split('\n')
    # .pipe es.map (data, next)->
    #   next null, data.replace trim, ''

    # .pipe es.map (data, next)->
    #   # transform csv to json
    #   obj = {}
    #   splitted = data.split ','
    #   for i in splitted
    #     i = i.replace trim, ''
    #     x = i.split('=')
    #     obj[(x[0].replace trim, '')] = x[1].replace trim, '' if i.length > 0
    #   next null, obj



unless module.parent
  server.listen 3002

  # process.stdin
  #   .pipe es.split()
  #   .pipe es.parse()
  #   .pipe es.map (data, done)->
  #     console.log data
  #     done null, data
  #   .pipe process.stdout