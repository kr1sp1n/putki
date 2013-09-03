server = require "#{__dirname}/lib/server"
port = 3000

server.listen port
console.log "Listening on port #{port}..."