restify = require 'restify'
request = require 'request'

putzi_config = 
  delimiter: ':'
  wildcard: true

putzi = (require "#{__dirname}/../putzi")(putzi_config)

# putzi.onAny (item)-> console.log "EVENT #{@event} id: #{item.id}"

server = restify.createServer
  name: 'putzi'

server.use restify.jsonp()
server.use restify.queryParser()
server.use restify.bodyParser()





###*
 * ROUTES
###

# GET all repos
server.get '/repo', (req, res, next)->
  putzi.getAllRepos (err, repos)->
    return next err if err?
    res.send repos

# GET all github pushes
server.get '/push', (req, res, next)->
  putzi.getAllPushes (err, pushes)->
    return next err if err?
    res.send pushes

# POST-RECEIVE HOOK
server.post '/github', (req, res, next)->
  payload = if typeof req.params.payload == 'object' then req.params.payload else JSON.parse req.params.payload
  putzi.receivePush payload, (err, push)->
    return next err if err?
    # set status on github
    commit_id = payload.after
    request.post
      url: "https://api.github.com/repos/kr1sp1n/putzi/statuses/#{commit_id}"
      auth:
        user: 'kr1sp1n'
        pass: 'githubBox23'
      json:
        state: "pending"
    ,(err, req, github_res)->
      return next err if err?
      res.send github_res




unless module.parent?
  server.listen 8080, ->
    console.log "#{server.name} listening at #{server.url}"

module.exports = server