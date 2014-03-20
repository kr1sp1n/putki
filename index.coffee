server = (require "#{__dirname}/lib/server")()
port = Number(process.env.PORT || 3000);

server.listen port, ->
  console.log "#{server.name} listening at #{server.url}"