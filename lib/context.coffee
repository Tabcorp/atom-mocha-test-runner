fs     = require 'fs'
path   = require 'path'
util   = require 'util'

exports.find = (testFile) ->
  root = closestPackage testFile
  if root
    root: root
    test: path.relative root, testFile
    mocha: path.join 'node_modules', '.bin', 'mocha'
  else
    root: path.dirname testFile
    test: path.basename testFile
    mocha: 'mocha'

closestPackage = (folder) ->
  pkg = path.join folder, 'package.json'
  if fs.existsSync pkg
    folder
  else if folder is '/'
    null
  else
    closestPackage path.dirname(folder)
