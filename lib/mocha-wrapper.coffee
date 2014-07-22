fs     = require 'fs'
path   = require 'path'
util   = require 'util'
events = require 'events'
spawn  = require('child_process').spawn

module.exports = class MochaWrapper extends events.EventEmitter

  constructor: (@testFile, @testName) ->

  run: ->

    root = closestPackage @testFile
    return @emit 'error', 'Could not find package.json' unless root
    relativeTestFile = path.relative root, @testFile

    @emit 'output', 'Root folder: ' + root + '\n'
    @emit 'output', 'Test file: ' + relativeTestFile + '\n'
    @emit 'output', 'Selected test: ' + (@testName or '<all>') + '\n'

    flags = [
      relativeTestFile
      '--no-colors'
    ]

    if @testName
      flags.push '--grep'
      flags.push @testName

    opts =
      cwd: root
      env: process.env

    binary = path.join 'node_modules', '.bin', 'mocha'
    mocha = spawn binary, flags, opts
    mocha.stdout.on 'data', (data) => @emit 'output', data.toString()
    mocha.stderr.on 'data', (data) => @emit 'output', data.toString()

    mocha.on 'exit', (code) =>
      if code is 0
        @emit 'success'
      else
        @emit 'failure'

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
