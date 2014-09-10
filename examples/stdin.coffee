es = require 'event-stream'
Stream = require('stream').Stream

lists = {}

class CreatePipe extends Stream
  constructor: (config, done)->
    done null

class Pipeline

  constructor: (config, done)->
    @pipes = []
    if typeof config == 'function'
      done = config
    done null, @

  add: (pipe)->
    @pipes.push pipe
    return @

  create: (data, done)->
    lists[data.id] = data
    done null, data
  

module.export = (config, done)->
  return new Pipeline config, done

unless module.parent
  p = new Pipeline (err, pipeline)->
    return err if err
    pipeline
      .add process.stdin
      .add process.stdout

    x = process.stdin
      .pipe es.split()
      .pipe es.parse()
      .pipe es.map (data, next)->
        pipeline.create data, next
    x
      .pipe es.stringify()
      .pipe process.stdout
