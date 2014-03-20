EventEmitter2 = require('eventemitter2').EventEmitter2

class Putki extends EventEmitter2

  constructor: (@config)->
    @db = (require "#{__dirname}/db")(@config?.db)
    # Destructuring assignment as short cuts to models
    {@Repository, @Push, @Job, @Step} = @db.models
    # pass Eventemitter2 config
    super @config

  ###*
   * GENERAL
  ###

  dropCollection: (model, done)->
    model.count (err, count)->
      return done err if err?
      unless count == 0
        model.collection.drop done
      else
        done null

  getById: (model, id, done)->
    model.findOne {"_id" : id}, done

  getAll: (model, done)->
    model.find {}, {_id: 0, __v: 0}, done

  ###*
   * REPOSITORY
  ###
  destroyAllRepositories: (done)->
    @dropCollection @Repository, done

  createRepository: (data, done)->
    @Repository.findOne {github_id: data.github_id}, (err, repo)=>
      return done err if err?
      if repo?
        repo.name = data.name
        repo.url = data.url
        repo.save (err)=>
          done err, repo
      else
        @Repository.create data, done

  getAllRepositories: (done)->
    @getAll @Repository, done

  getRepositoryById: (id, done)->
    @getById @Repository, id, done

  getRepositoryByGithubId: (github_id, done)->
    @Repository.findOne {'github_id': github_id}, done

  # noSuchTableError: (err)->
  #   return Boolean(err?.message and ~err.message.indexOf 'no such table')

  # hasTable: (table_name, done)->
  #   @db.run "SELECT 1 FROM #{table_name}", (err, result)=>
  #     no_such_table = @noSuchTableError err
  #     return done err, result if err and not no_such_table
  #     done null, not no_such_table

  # createTable: (model, done)->
  #   columns = for name, property of model.properties
  #     "#{name} #{json2sqlite[property.type]}" + (if name=='id' then " PRIMARY KEY")
  #   @db.run "CREATE TABLE IF NOT EXISTS #{model.title.toLowerCase()} (#{columns.join ', '})", done

  # insert: (model, data, done)->
  #   table_name = model.title.toLowerCase()

  #   @createTable model, (err)=>
  #     return done err if err?
  #     keys = Object.keys(data).map (key) -> "$#{key}"
  #     values = {}
  #     column_names = []
  #     for key in keys
  #       column_names.push key.split('$')[1]
  #       values[key] = data[key.split('$')[1]]
  #     @db.run "INSERT INTO #{table_name} (#{column_names.join ', '}) VALUES (#{keys.join ', '})"
  #     , values
  #     , (err)=>
  #       already_exists = Boolean(err?.message and ~err.message.indexOf 'column id is not unique')
  #       # return done new Error "Repo with id '#{data.id}' already exists" if already_exists
  #       return done err if err and not already_exists
  #       @emit "#{table_name}:add", data unless err
  #       @getById model, data.id, done

  # getAll: (model, done)->
  #   @createTable model, (err)=>
  #     return done err if err?
  #     @db.all "SELECT * FROM #{model.title.toLowerCase()}", done
    
  # getById: (model, id, done)->
  #   table_name = model.title.toLowerCase()
  #   @db.get "SELECT * FROM #{table_name} WHERE id = $id",
  #     $id: id
  #   , done

  # ###*
  #  * REPO
  # ###

  # createRepo: (data, done)->
  #   @insert Repo, data, done

  # hasRepo: (id, done)->
  #   @db.get "SELECT * from 'repo' WHERE id = $id",
  #     $id: id
  #   , (err, repo)->
  #     has_repo = not Boolean(err?.message and (~err.message.indexOf 'no such table' or not repo?))
  #     done null, has_repo, repo

  # deleteAllRepos: (done)->
  #   @dropTable 'repo', done



  ###*
   * PUSHES from github via post-receive web hook -> https://help.github.com/articles/post-receive-hooks
  ###

  destroyAllPushes: (done)->
    @dropCollection @Push, done
  
  createPush: (data, done)->
    @Push.create data, done

  receivePush: (payload, done)->
    repository = payload.repository
    @createRepository
      github_id: repository.id
      name: repository.name
      url: repository.url
    , (err, repository)=>
      return done err if err?
      data =
        payload : payload  # save payload received from github
        repository: repository._id # link with repo
      @createPush data, (err, push)=>
        return done err if err?
        repository.pushes.push push # update repo
        repository.save (err)->
          return done err if err?
          done null, push

  getAllPushes: (done)->
    @getAll @Push, done

  getPushById: (id, done)->
    @getById @Push, id, done

module.exports = (config)->
  new Putki config