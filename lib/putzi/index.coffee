sqlite3 = require('sqlite3').verbose()
EventEmitter2 = require('eventemitter2').EventEmitter2

class Putzi extends EventEmitter2

  constructor: (@config)->
    @db = new sqlite3.Database "#{if @config?.db? then @config.db else ':memory:'}"

  dropTable: (table_name, done)->
    @db.run "DROP TABLE IF EXISTS #{table_name}", done

  hasTable: (table_name, done)->
    @db.run "SELECT 1 FROM #{table_name}", (err, result)->
      no_such_table = Boolean(err?.message and ~err.message.indexOf 'no such table')
      return done err, result if err and not no_such_table
      done null, not no_such_table

  getAllFrom: (table_name, done)->
    @db.all "SELECT * FROM #{table_name}", done

  createRepoTable: (done)->
    @db.run "CREATE TABLE repo (id PRIMARY KEY, name, url)", done

  insertRepo: (data, done)->
    @db.run "INSERT INTO repo VALUES ($id, $name, $url)",
      $id: data.id
      $name: data.name
      $url: data.url
    , (err)=>
      already_exists = Boolean(err?.message and ~err.message.indexOf 'column id is not unique')
      return done new Error "Repo with id '#{data.id}' already exists" if already_exists
      @emit 'inserted repo', data
      done err, data

  createRepo: (data, done)->
    @hasTable 'repo', (err, has_table)=>
      return done err if err
      if has_table
        @insertRepo data, done
      else
        @createRepoTable (err)=>
          return done err if err
          @insertRepo data, done

  getAllRepos: (done)->
    table_name = 'repo'
    @hasTable table_name, (err, has_table)=>
      return done err if err
      if has_table
        @getAllFrom table_name, done
      else
        @createRepoTable (err)=>
          return done err if err
          @getAllFrom table_name, done

module.exports = (config)-> new Putzi config