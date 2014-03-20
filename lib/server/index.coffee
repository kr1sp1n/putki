restify = require 'restify'
request = require 'request'

# putki.onAny (item)-> console.log "EVENT #{@event} id: #{item.id}"

init = (config)->
  putki_config = 
    delimiter: ':'
    wildcard: true
    db: config?.db
  putki = (require "#{__dirname}/../putki")(putki_config)

  server = restify.createServer
    name: 'putki'

  server.use restify.jsonp()
  server.use restify.queryParser()
  server.use restify.bodyParser()

  ###*
   * ROUTES
  ###

  server.get '/', (req, res, next)->
    # deliver angular app
    res.send 'Welcome to putki'

  # GET all repos
  server.get '/repo', (req, res, next)->
    putki.getAllRepositories (err, repos)->
      return next err if err?
      res.send repos

  # GET all github pushes
  server.get '/push', (req, res, next)->
    putki.getAllPushes (err, pushes)->
      return next err if err?
      res.send pushes

  # POST-RECEIVE HOOK
  server.post '/github', (req, res, next)->
    payload = if typeof req.params.payload == 'object' then req.params.payload else JSON.parse req.params.payload
    putki.receivePush payload, (err, push)->
      return next err if err?
      # set status on github
      commit_id = payload.after

      request.post
        url: "https://api.github.com/repos/kr1sp1n/putki/statuses/#{commit_id}"
        auth:
          user: 'kr1sp1n'
          pass: 'githubBox23'
        json:
          state: "pending"
      ,(err, req, github_res)->
        return next err if err?
        res.send github_res

  return server

unless module.parent?
  server = init()
  server.listen 8080, ->
    console.log "#{server.name} listening at #{server.url}"

module.exports = (config)-> init config