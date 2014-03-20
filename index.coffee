config =
  db: process.env.MONGOHQ_URL || 'mongodb://localhost/putki_test'

console.log config

server = (require "#{__dirname}/lib/server")(config)
port = Number(process.env.PORT || 3000);

server.listen port, ->
  console.log "#{server.name} listening at #{server.url}"