should = require 'should'
Putki = require "#{__dirname}/../../lib/putki"

generatePipes = (putki, count, done)->
  pipes = ({title: "Pipe "+num} for num in [1..count])
  i = 0
  cb = (err, pipe)->
    i++
    return done err if err
    return done() if i == pipes.length
  putki.Pipe.create data, cb for data in pipes


describe 'Putki module', ->
  it 'should export only one function that returns a Putki instance', (done)->
    Putki.should.be.a.Function
    p = Putki()
    p.should.be.an.Object
    done()

describe 'Putki instance', ->
  putki = null
  config = 
    db: 'memory'

  beforeEach ->
    putki = Putki config

  describe 'addPipe(data, cb)', ->
    it 'should add a new Pipe to the list of all Pipes', (done)->
      data =
        title: 'My new Pipe'
      putki.addPipe data, (err, pipe)->
        putki.Pipe.all (err, pipes)->
          pipes.should.have.length 1
          pipes[0].should.have.property 'title', data.title
          done err

  describe 'getPipe(id, cb)', ->
    beforeEach (done)->
      generatePipes putki, 3, done

    it 'should return a Pipe by its id', (done)->
      putki.getPipe 2, (err, pipe)->
        pipe.should.have.property 'title', 'Pipe 2'
        done err

      
