express = require 'express'
app = express()
app.use express.bodyParser()

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

app.post '/job/:id/github', (req, res)->
  res.send ""

unless module.parent?
  app.listen 3000

module.exports = app