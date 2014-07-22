fs    = require 'fs'
path  = require 'path'
util  = require 'util'
spawn = require('child_process').spawn

closestPackage = (folder) ->
  pkg = path.join folder, 'package.json'
  console.log 'pkg', pkg
  if fs.existsSync pkg
    console.log 'found!'
    folder
  else if folder is '/'
    null
  else
    closestPackage path.dirname(folder)

exports.run = (testFile, testName, callback) ->

  root = closestPackage testFile
  if not root
    return callback 'Could not find package.json'

  relativeTest = path.relative root, testFile
  binary = path.join 'node_modules', '.bin', 'mocha'

  callback 'Root folder: ' + root + '\n'
  callback 'Test file: ' + relativeTest + '\n'
  callback 'Selected test: ' + (testName or 'ALL') + '\n'
  callback '\n'

  flags = [
    relativeTest
    '--no-colors'
  ]

  if testName
    flags.push '--grep'
    flags.push testName

  opts =
    cwd: root
    env: process.env

  mocha = spawn binary, flags, opts
  mocha.stdout.on 'data', (data) -> callback data.toString()
  mocha.stderr.on 'data', (data) -> callback data.toString()
  mocha.on 'exit', (code) -> console.log 'child process exited with code ' + code
