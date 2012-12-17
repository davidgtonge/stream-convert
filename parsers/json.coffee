JSONStream = require "JSONStream"
fs = require "fs"

exports.reader = (filename, dataKey) ->
  readStream = fs.createReadStream(filename)
  parser = JSONStream.parse([dataKey, true])
  readStream.pipe(parser)
  parser


exports.writer = (filename, parentObj) ->
  writeStream = fs.createWriteStream(filename)
  if parentObj
    open = '{"' + parentObj + '": [\n'
    sep='\n,\n'
    close = '\n] }\n'
    stringify = JSONStream.stringify(open, sep, close)
  else
    stringify = JSONStream.stringify()
  stringify.pipe(writeStream)
  stringify
