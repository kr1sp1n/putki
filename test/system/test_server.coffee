request = require 'request'
should = require 'should'
nock = require 'nock'
fs = require 'fs'

db_file = "#{__dirname}/../../db/test.sqlite"
# config =
#   db : db_file
config = {}
putki = (require "#{__dirname}/../../lib/putki")()

server = (require "#{__dirname}/../../lib/server")(config)

port = 3099

github_payload = require "#{__dirname}/fixtures/github_payload"
github_response = require "#{__dirname}/fixtures/github_response"

# stub github
github = nock('https://api.github.com')
          .persist()
          .post("/repos/kr1sp1n/putki/statuses/#{github_payload.after}", {state: 'pending'})
          .reply(200, github_response)

endpoint = "http://localhost:#{port}"

postPush = (done)->
  request.post
    url: "#{endpoint}/github"
    form:
      payload: github_payload
    json: true
  , done

getAllRepos = (done)->request.get {url: "#{endpoint}/repo", json: true}, done

describe 'server', ->
  @timeout 2000
  before (done)->
    server.listen port, done

  # describe 'POST /github', ->
  #   it "should set the state of the after commit to 'pending'", (done)->
  #     postPush (err, res, body)->
  #       return done err if err?
  #       body.should.have.property 'state', 'pending'
  #       done null

  # describe 'GET /repo', ->
  #   before (done)->
  #     @data1 = {id:'1', name:'Repo1', url: 'https://github.com/kr1sp1n/repo1'}
  #     @data2 = {id:'2', name:'Repo2', url: 'https://github.com/kr1sp1n/repo2'}
  #     putki.deleteAllRepos (err)=>
  #       return done err if err?
  #       putki.createRepo @data1, (err, repo1)=>
  #         return done err if err?
  #         putki.createRepo @data2, (err, repo2)=>
  #           done err

  #   it 'should get all saved repos', (done)->
  #     getAllRepos (err, res, body)=>
  #       return done err if err?
  #       body.should.have.length 2
  #       body[0].should.eql @data1
  #       body[1].should.eql @data2
  #       done null
