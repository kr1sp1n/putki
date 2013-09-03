should = require "should"

config = {}
putzi = (require "#{__dirname}/../lib/putzi")(config)

describe 'putzi', ->

  describe 'createRepo()', ->
    
    beforeEach (done)->    
      @repo_data =
        name: "putzi"
        url: "https://github.com/kr1sp1n/putzi"
      putzi.dropTable 'repo', done

    it 'should save a new repo', (done)->
      putzi.createRepo @repo_data, (err, repo)=>
        repo.should.have.property 'name', @repo_data.name
        done err

    it 'should create a repo db table if it not exists', (done)->
      putzi.hasTable 'repo', (err, has_table)=>
        has_table.should.not.be.ok
        putzi.createRepo @repo_data, (err, repo)->
          putzi.hasTable 'repo', (err, has_table)->
            has_table.should.be.ok
            done err