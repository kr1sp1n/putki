mongoose = require 'mongoose'
moment = require 'moment'

module.exports = (config)->
  db = new mongoose.Mongoose()
  Schema = db.Schema

  RepositorySchema = new Schema
    github_id :
      type: String
      required: true
      unique: true
    name      : String
    url       : String
    pushes    : [{ type: Schema.Types.ObjectId, ref: 'Push' }]

  Repository = db.model 'Repository', RepositorySchema

  PushSchema = new Schema
    repository : { type: Schema.Types.ObjectId, ref: 'Repository', required: true}
    payload     : {}
    received_at :
      type: Date
      default: moment.utc().toDate()

  Push = db.model 'Push', PushSchema

  JobSchema = new Schema
    id          : String
    name        : String

  Job = db.model 'Job', JobSchema

  StepSchema = new Schema
    id          : String
    command     : String

  Step = db.model 'Step', StepSchema

  db.connect config, 'putki_test'

  return db