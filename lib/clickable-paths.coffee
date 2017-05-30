fs      = require 'fs'
path    = require 'path'
{Point} = require 'atom'
{$}     = require 'atom-space-pen-views'

PATH_REGEX = /((?:\w:)?[^:\s\(\)]+):(\d+):(\d+)/g

module.exports.link = (line, root) ->
  return null unless line?
  line.replace(PATH_REGEX, "<a class=\"flink\" data-root=\"#{root}\">$&</a>")

module.exports.attachClickHandler = ->
  $(document).on 'click', '.flink', module.exports.clicked

module.exports.removeClickHandler = ->
  $(document).off 'click', '.flink', module.exports.clicked

module.exports.clicked = ->
  extendedPath = this.innerHTML
  rootPath = this.getAttribute 'data-root'
  module.exports.open(path.join rootPath, extendedPath)

module.exports.open = (extendedPath) ->
  parts = PATH_REGEX.exec(extendedPath)
  return unless parts?

  [filename,row,col] = parts.slice(1)
  return unless filename?

  unless fs.existsSync(filename)
    alert "File not found: #{filename}"
    return

  atom.workspace.open(filename)
  .then ->
    return unless row?

    # align coordinates 0-index-based
    row = Math.max(row - 1, 0)
    col = Math.max(~~col - 1, 0)
    position = new Point(row, col)

    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    editor.scrollToBufferPosition(position, center:true)
    editor.setCursorBufferPosition(position)
