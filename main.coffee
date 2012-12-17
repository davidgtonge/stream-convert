argv = require('optimist')
  .usage('Usage: $0 -c [file] -o [file]')
  .demand(['c','o'])
  .argv

path = require "path"

inputExtension = path.extname argv.c
outputExtension = path.extname argv.o
inputFile = path.join __dirname, argv.c
outputFile = path.join __dirname, argv.o

reader = switch inputExtension
  when ".xml" then require("./parsers/xml").reader
  when ".json" then require("./parsers/json").reader
  when ".csv" then require("./parsers/csv").reader
  else
    console.log "Input file extension is not .csv, .xml, or .json"
    process.exit()

writer = switch outputExtension
  when ".xml" then require("./parsers/xml").writer
  when ".json" then require("./parsers/json").writer
  when ".csv" then require("./parsers/csv").writer
  else
    console.log "Output file extension is not .csv, .xml or .json"
    process.exit()

start = (new Date).getTime()
reader(inputFile, "/nodes/node").pipe(writer(outputFile, "nodes")).on "end", ->
  console.log "Finished in #{(new Date).getTime() - start}ms"


console.log "Converting #{argv.c} to #{argv.o}"