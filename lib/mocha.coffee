fs     = require 'fs'
path   = require 'path'
util   = require 'util'
events = require 'events'
spawn  = require('child_process').spawn

module.exports = class MochaWrapper extends events.EventEmitter

  constructor: (@context) ->

  run: ->

    console.debug 'Root folder:', @context.root
    console.debug 'Test file:', @context.test
    console.debug 'Selected test:', @grep or '<all>'

    flags = [
      @context.mocha
      @context.test
      '--no-colors'
    ]

    if @context.grep
      flags.push '--grep'
      flags.push @context.grep

    opts =
      cwd: @context.root
      env: process.env

    opts.env["ATOM_SHELL_INTERNAL_RUN_AS_NODE"] = 1
    node = (if process.platform is "darwin" then path.resolve(process.resourcesPath, "..", "Frameworks", "Atom Helper.app", "Contents", "MacOS", "Atom Helper") else process.execPath)

    mocha = spawn node, flags, opts
    mocha.stdout.on 'data', (data) => @emit 'output', data.toString()
    mocha.stderr.on 'data', (data) => @emit 'output', data.toString()

    mocha.on 'exit', (code) =>
      if code is 0
        @emit 'success'
      else
        @emit 'failure'
