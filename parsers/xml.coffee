xml2js = require './xml2'
xml = require "xml"
Stream = require "stream"
_ = require "underscore"
fs = require "fs"

exports.reader = (filename, dataNode) ->
  parser = new xml2js.Parser {dataNode}
  parser.parse(filename)
  parser

arrayToNodes = (data) ->
  if _.isArray(data)
    for item, index in data
      data[index] = {node:item}
  data

class XMLWriter extends Stream
  writable:true
  readable:true
  started: false
  write: (obj) =>
    if not @started
      @emit "data", '<?xml version="1.0" encoding="UTF-8"?><nodes>\n'
      @started = true
    out =
      node:[]
    for key, val of obj
      val = arrayToNodes(val)
      o = {}
      o[key] = val
      out.node.push o
    @emit "data", xml(out) + "\n"

  end: (obj) =>
    if arguments.length then @write(obj)
    @emit "data", "</nodes>"
    @emit "end"
    @writable = false
  destroy: =>
    @writable = false



exports.writer = (filename, root) ->
  writeStream = fs.createWriteStream(filename)
  xmlStream = new XMLWriter
  xmlStream.pipe(writeStream)
  xmlStream