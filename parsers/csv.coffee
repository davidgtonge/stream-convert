csv = require "ya-csv"
Stream = require "stream"
_ = require "underscore"
fs = require "fs"
class CSVWriteStream extends Stream
  writable:true
  columnCache: []
  columnsSent: false

  parseWrite: (obj) ->
    out = []
    for key in @columns
      data = obj[key]
      unless _.isString(data) or _.isNumber(data)
        data = JSON.stringify(data)
      out.push data
    @csvWriter.writeRecord out

  write: (obj) =>
    if @columnsSent
      @parseWrite(obj)
    else
      if @columnCache.length is 5
        @columns = _.unique _.flatten (_.keys(item) for item in @columnCache)
        @csvWriter.writeRecord(@columns)
        @columnsSent = true
        @parseWrite(obj) for obj in @columnCache
      else
        @columnCache.push obj

  end: (obj) =>
    if arguments.length then @write(obj)
    @emit "end"
    @writable = false
  destroy: =>
    @writable = false



exports.reader = (filename) ->
  stream = new Stream
  reader = csv.createCsvFileReader(filename, { columnsFromHeader: true })
  reader.on 'data', (data) -> stream.emit "data", data
  reader.on "end", -> stream.emit "end"
  reader.on "error", (err) -> stream.emit "error", err
  stream


exports.writer = (filename) ->
  writeStream = fs.createWriteStream(filename)
  stream = new CSVWriteStream
  stream.csvWriter = csv.createCsvStreamWriter(writeStream)
  stream