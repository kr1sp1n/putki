should = require "should"

config = {}

putzi = (require "#{__dirname}/../lib/putzi")(config)
github_payload = require "#{__dirname}/system/fixtures/github_payload"

describe 'putzi', ->

  describe 'createRepo(data, done)', ->
    
    beforeEach (done)->    
      @repo_data =
        id: "12434611"
        name: "putzi"
        url: "https://github.com/kr1sp1n/putzi"
      putzi.dropTable 'repo', done

    it 'should save a new repo', (done)->
      putzi.createRepo @repo_data, (err, repo)=>
        return done err if err?
        repo.should.have.property 'id', @repo_data.id
        repo.should.have.property 'name', @repo_data.name
        repo.should.have.property 'url', @repo_data.url
        done null

    it 'should create a repo db table if it not exists', (done)->
      putzi.hasTable 'repo', (err, has_table)=>
        return done err if err?
        has_table.should.not.be.ok
        putzi.createRepo @repo_data, (err, repo)->
          return done err if err?
          putzi.hasTable 'repo', (err, has_table)->
            return done err if err
            has_table.should.be.ok
            done null

    it 'should return the repo if it already exists', (done)->
      putzi.createRepo @repo_data, (err, repo)=>
        return done err if err?
        putzi.createRepo
          id: @repo_data.id
          name: "Any other name"
          url: "Any other url"
        , (err, repo)=>
          return done err if err?
          repo.should.have.property 'id', @repo_data.id
          done null

    it 'should not modify the repo if it already exists', (done)->
      putzi.createRepo @repo_data, (err, repo)=>
        return done err if err?
        putzi.createRepo
          id: @repo_data.id
          name: "Any other name"
          url: "Any other url"
        , (err, repo)=>
          return done err if err?
          repo.should.have.property 'id', @repo_data.id
          repo.should.have.not.property 'name', 'Any other name'
          done null

  describe 'receivePush(payload, done)', ->

    beforeEach (done)->
      @push_data = github_payload
      putzi.dropTable 'repo', (err)->
        return done err if err?
        putzi.dropTable 'push', done

    it 'should save a new push', (done)->
      putzi.receivePush @push_data, (err, push)->
        return done err if err?
        putzi.getPushById push.id, (err, saved_push)->
          return done err if err?
          saved_push.should.have.property 'id'
          saved_push.should.have.property 'payload'
          saved_push.should.have.property 'received_at'
          saved_push.should.have.property 'repo_id'
          saved_push.should.eql push
          done null


    it 'should create a new repo if it not exists', (done)->
      putzi.hasRepo @push_data.repository.id, (err, has_repo, repo)=>
        return done err if err?
        has_repo.should.not.be.ok
        putzi.receivePush @push_data, (err, push)=>
          return done err if err?
          push.should.have.property 'repo_id', String(@push_data.repository.id)
          done null


