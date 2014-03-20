config =
  db: process.env.MONGOHQ_URL || 'localhost'

server = (require "#{__dirname}/lib/server")(config)
port = Number(process.env.PORT || 3000);

server.listen port, ->
  console.log "#{server.name} listening at #{server.url}"