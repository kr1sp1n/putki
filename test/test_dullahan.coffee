should = require "should"

config = {}
dullahan = (require "#{__dirname}/../lib/dullahan")(config)

github_payload = require "#{__dirname}/system/fixtures/github_payload"

describe 'dullahan', ->

  describe 'createRepository(data, done)', ->
    
  #   beforeEach (done)->    
  #     @repo_data =
  #       github_id: "12434611"
  #       name: "dullahan"
  #       url: "https://github.com/kr1sp1n/dullahan"
  #     dullahan.destroyAllRepositories done

  #   it 'should save a new repository if not exists', (done)->
  #     dullahan.createRepository @repo_data, (err, repo)=>
  #       return done err if err?
  #       repo.should.have.property 'github_id', @repo_data.github_id
  #       repo.should.have.property 'name', @repo_data.name
  #       repo.should.have.property 'url', @repo_data.url
  #       dullahan.Repository.count {}, (err, count)=>
  #         return done err if err?
  #         count.should.equal 1
  #         done null

  #   it 'should update a repository if already exists', (done)->
  #     dullahan.createRepository @repo_data, (err, repo)=>
  #       return done err if err?
  #       dullahan.createRepository
  #         github_id: @repo_data.github_id
  #         name: "Any other name"
  #         url: "Any other url"
  #       , (err, repo)=>
  #         return done err if err?
  #         repo.should.have.property 'github_id', @repo_data.github_id
  #         repo.should.have.property 'name', 'Any other name'
  #         repo.should.have.property 'url', 'Any other url'
  #         dullahan.Repository.count {}, (err, count)=>
  #           return done err if err?
  #           count.should.equal 1
  #           done null

  # describe 'receivePush(payload, done)', ->

  #   beforeEach (done)->
  #     @push_data = github_payload
  #     dullahan.destroyAllRepositories (err)->
  #       return done err if err?
  #       dullahan.destroyAllPushes (err)->
  #         done err

  #   it 'should save a new push', (done)->
  #     dullahan.receivePush @push_data, (err, push)->
  #       return done err if err?
  #       dullahan.getPushById push.id, (err, saved_push)->
  #         return done err if err?
  #         saved_push.should.have.property 'id', push.id
  #         saved_push.should.have.property 'payload'
  #         saved_push.should.have.property 'received_at'
  #         push.received_at.should.eql saved_push.received_at
  #         saved_push.should.have.property 'repository'
  #         saved_push.repository.should.eql push.repository
  #         done null

  #   it 'should create a new repo if repo not exists', (done)->
  #     dullahan.getRepositoryByGithubId @push_data.repository.id, (err, repo)=>
  #       return done err if err?
  #       should.not.exist repo
  #       dullahan.receivePush @push_data, (err, push)=>
  #         return done err if err?
  #         dullahan.getRepositoryById push.repository, (err, repo)=>
  #           return done err if err?
  #           repo.github_id.should.equal String(@push_data.repository.id)
  #           done null

  # describe 'getAllPushes(done)', ->

  #   beforeEach (done)->
  #     @push_data = github_payload
  #     dullahan.destroyAllPushes (err)->
  #       done err

  #   it 'should return all pushes in the db', (done)->
  #     dullahan.receivePush @push_data, (err, push)=>
  #       return done err if err?
  #       dullahan.receivePush @push_data, (err, push)=>
  #         return done err if err?
  #         dullahan.getAllPushes (err, pushes)=>
  #           return done err if err?
  #           pushes.length.should.equal 2
  #           done()


