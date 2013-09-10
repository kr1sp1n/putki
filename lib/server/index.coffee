express = require 'express'
app = express()
app.use express.bodyParser()
request = require 'request'

putzi_config = {}
putzi = (require "#{__dirname}/../putzi")(putzi_config)

putzi.onAny (value)->
  console.log "EVENT"
  console.log @event
  console.log value

app.get '/', (req, res)->
  res.send "HELLO"

app.post '/repo', (req, res)->
  putzi.createRepo req.body, (err, repo)->
    return res.jsonp 500, { message : err.message } if err?
    res.jsonp repo

app.get '/repo', (req, res)->
  putzi.getAllRepos (err, repos)->
    console.log err if err
    return res.jsonp 500, err if err
    res.jsonp repos

app.post '/job', (req, res)->
  res.send ""

app.post '/github', (req, res)->

  putzi.createPush req.body.payload, (err)->
    return res.jsonp 500, err if err
    
    # set status
    commit_id = req.body.payload.after
    request.post
      url: "https://api.github.com/repos/kr1sp1n/putzi/statuses/#{commit_id}"
      auth:
        user: 'kr1sp1n'
        pass: 'githubBox23'
      json:
        state: "pending"
    ,(err, req, github_res)->
      return res.jsonp 500, err if err
      res.jsonp github_res
  



unless module.parent?
  app.listen 3000

module.exports = app