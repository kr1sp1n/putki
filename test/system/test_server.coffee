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

describe 'server', ->
  @timeout 10000
  before ->
    server.listen port
  describe 'post-receive hook', ->
    it 'should parse a POST request from github', (done)->
      postPush (err, req, res)->
        res.should.have.property 'state', 'pending'
        done()