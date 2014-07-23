path = require 'path'

exports.fromEditor = (editor) ->
  row = editor.getCursorScreenRow()
  line = editor.lineForBufferRow row
  test = getTestName line
  return test

getTestName = (line) ->
  describe = extractMatch line, /describe\s*\(?\s*[\'\"](.*)[\'\"]/
  it       = extractMatch line,       /it\s*\(?\s*[\'\"](.*)[\'\"]/
  describe or it or null

extractMatch = (line, regex) ->
  matches = regex.exec line
  if matches and matches.length >= 2
    matches[1]
  else
    null
