sqlite3 = require('sqlite3').verbose()
EventEmitter2 = require('eventemitter2').EventEmitter2
moment = require 'moment'
uuid = require 'node-uuid'

###*
 * MAP DATATYPES FROM JSON SCHEMA TO SQLITE TO GENERATE TABLES
###

json2sqlite = 
  "integer": "INTEGER"
  "string": "TEXT"
  "null": "NULL"
  "boolean": " INTEGER(1)"

###*
 * JSON Schema
###
Repo = 
  title: 'Repo'
  description: 'A github repository'
  type: 'object'
  properties:
    id:
      description: 'The unique identifier for a github repository'
      type: 'string'
    name:
      description: 'The name of the github repository'
      type: 'string'
    url:
      description: 'The URL of the github repository'
      type: 'string'
  required: ['id', 'name', 'url']

Push =
  title: 'Push'
  description: 'A github push via post-receive hook'
  type: 'object'
  properties:
    id:
      description: 'The unique identifier (UUID) for a push'
      type: 'string'
    payload:
      description: 'The payload that was send by github via post-receive hook'
      type: 'string'
    received_at:
      description: 'The time as unix timestamp when the push was received at the ci server'    
      type: 'integer'
    repo_id:
      description: 'The id of the related Repo'
      type: 'string'

  required: ['payload', 'received_at']
  links: [
    {rel: 'Repo', href: '/repo/{repo_id}'}
  ]

resources = 
  'repo': Repo
  'push': Push

class Putzi extends EventEmitter2

  constructor: (@config)->
    @db = new sqlite3.Database "#{if @config?.db? then @config.db else ':memory:'}"
    super @config

  ###*
   * GENERAL DATABASE FUNCTIONS
  ###
  dropTable: (table_name, done)->
    @db.run "DROP TABLE IF EXISTS #{table_name}", done

  noSuchTableError: (err)->
    return Boolean(err?.message and ~err.message.indexOf 'no such table')

  hasTable: (table_name, done)->
    @db.run "SELECT 1 FROM #{table_name}", (err, result)=>
      no_such_table = @noSuchTableError err
      return done err, result if err and not no_such_table
      done null, not no_such_table

  createTable: (model, done)->
    columns = for name, property of model.properties
      "#{name} #{json2sqlite[property.type]}" + (if name=='id' then " PRIMARY KEY")
    @db.run "CREATE TABLE IF NOT EXISTS #{model.title.toLowerCase()} (#{columns.join ', '})", done

  insert: (model, data, done)->
    table_name = model.title.toLowerCase()

    @createTable model, (err)=>
      return done err if err?
      keys = Object.keys(data).map (key) -> "$#{key}"
      values = {}
      column_names = []
      for key in keys
        column_names.push key.split('$')[1]
        values[key] = data[key.split('$')[1]]
      @db.run "INSERT INTO #{table_name} (#{column_names.join ', '}) VALUES (#{keys.join ', '})"
      , values
      , (err)=>
        already_exists = Boolean(err?.message and ~err.message.indexOf 'column id is not unique')
        # return done new Error "Repo with id '#{data.id}' already exists" if already_exists
        return done err if err and not already_exists
        @emit "#{table_name}:add", data unless err
        @getById model, data.id, done

  getAll: (model, done)->
    @createTable model, (err)=>
      return done err if err?
      @db.all "SELECT * FROM #{model.title.toLowerCase()}", done
    
  getById: (model, id, done)->
    table_name = model.title.toLowerCase()
    @db.get "SELECT * FROM #{table_name} WHERE id = $id",
      $id: id
    , done

  ###*
   * REPO
  ###

  createRepo: (data, done)->
    @insert Repo, data, done

  hasRepo: (id, done)->
    @db.get "SELECT * from 'repo' WHERE id = $id",
      $id: id
    , (err, repo)->
      has_repo = not Boolean(err?.message and (~err.message.indexOf 'no such table' or not repo?))
      done null, has_repo, repo

  getAllRepos: (done)->
    @getAll Repo, done



  ###*
   * PUSH from github via post-receive web hook -> https://help.github.com/articles/post-receive-hooks
  ###

  receivePush: (payload, done)->
    repository = payload.repository
    @createRepo
      id: repository.id
      name: repository.name
      url: repository.url
    , (err, repo)=>
      return done err if err?
      data =
        id: uuid.v1() # time-based UUID
        payload : JSON.stringify payload  # save payload received from github
        repo_id : repo.id  # link with repo
        received_at : moment().unix()
      @createPush data, done

  createPush: (data, done)->
    @insert Push, data, done

  getAllPushes: (done)->
    @getAll Push, done

  getPushById: (id, done)->
    @getById Push, id, done

module.exports = (config)-> new Putzi config