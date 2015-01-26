path      = require 'path'
localeval = require 'localeval'

exports.fromEditor = (editor) ->
  row = editor.getCursorScreenPosition().row
  line = editor.lineTextForBufferRow row
  test = getTestName line
  return test

getTestName = (line) ->
  describe = extractMatch line, /describe\s*\(?\s*['"](.*)['"]/
  it       = extractMatch line,       /it\s*\(?\s*['"](.*)['"]/
  describe or it or null

extractMatch = (line, regex) ->
  matches = regex.exec line
  if matches and matches.length >= 2
    localeval "'#{matches[1]}'"
  else
    null
