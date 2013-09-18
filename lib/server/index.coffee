restify = require 'restify'
request = require 'request'

# dullahan.onAny (item)-> console.log "EVENT #{@event} id: #{item.id}"

init = (config)->
  dullahan_config = 
    delimiter: ':'
    wildcard: true
    db: config?.db
  dullahan = (require "#{__dirname}/../dullahan")(dullahan_config)

  server = restify.createServer
    name: 'dullahan'

  server.use restify.jsonp()
  server.use restify.queryParser()
  server.use restify.bodyParser()

  ###*
   * ROUTES
  ###

  # GET all repos
  server.get '/repo', (req, res, next)->
    dullahan.getAllRepositories (err, repos)->
      return next err if err?
      res.send repos

  # GET all github pushes
  server.get '/push', (req, res, next)->
    dullahan.getAllPushes (err, pushes)->
      return next err if err?
      res.send pushes

  # POST-RECEIVE HOOK
  server.post '/github', (req, res, next)->
    payload = if typeof req.params.payload == 'object' then req.params.payload else JSON.parse req.params.payload
    dullahan.receivePush payload, (err, push)->
      return next err if err?
      # set status on github
      commit_id = payload.after
      request.post
        url: "https://api.github.com/repos/kr1sp1n/dullahan/statuses/#{commit_id}"
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