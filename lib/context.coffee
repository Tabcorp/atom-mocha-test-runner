fs   = require 'fs'
path = require 'path'
util = require 'util'
selectedTest = require './selected-test'
isWindows = ///^win///.test process.platform

exports.find = (editor) ->
  root = closestPackage editor.getPath()
  if root
    mochaCommand = if isWindows then 'mocha.cmd' else 'mocha'
    mochaBinary = path.join root, 'node_modules', '.bin', 'mocha.cmd'
    if not fs.existsSync mochaBinary
      mochaBinary = 'mocha'
    root: root
    test: path.relative root, editor.getPath()
    grep: selectedTest.fromEditor editor
    mocha: mochaBinary
  else
    root: path.dirname editor.getPath()
    test: path.basename editor.getPath()
    grep: selectedTest.fromEditor editor
    mocha: 'mocha'

closestPackage = (folder) ->
  pkg = path.join folder, 'package.json'
  if fs.existsSync pkg
    folder
  else if folder is '/'
    null
  else
    closestPackage path.dirname(folder)
