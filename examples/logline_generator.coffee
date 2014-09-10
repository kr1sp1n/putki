es = require 'event-stream'
lists = ({ id: i, name: "list #{i}" } for i in [1..3])
reader = es.readArray lists
reader
  .pipe es.stringify()
  .pipe process.stdout