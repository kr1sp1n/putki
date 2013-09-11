request = require 'request'
should = require 'should'
server = require "#{__dirname}/../../lib/server"
port = 3099
github_payload = require "#{__dirname}/fixtures/github_payload"

postPush = (done)->
  request.post
    url: "http://localhost:#{port}/github"
    form:
      payload: github_payload
    json: true
  , done

describe 'putzi server', ->
  @timeout 5000
  before ->
    server.listen port
  describe 'POST /github', ->
    it "should set the state of the after commit to 'pending'", (done)->
      postPush (err, req, res)->
        res.should.have.property 'state', 'pending'
        done()