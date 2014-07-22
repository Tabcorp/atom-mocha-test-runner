fs     = require 'fs'
path   = require 'path'
util   = require 'util'
events = require 'events'
spawn  = require('child_process').spawn

module.exports = class MochaWrapper extends events.EventEmitter

  constructor: (@context, @testName) ->

  run: ->

    @emit 'output', 'Root folder: ' + @context.root + '\n'
    @emit 'output', 'Test file: ' + @context.test + '\n'
    @emit 'output', 'Selected test: ' + (@testName or '<all>') + '\n'

    flags = [
      @context.test
      '--no-colors'
    ]

    if @testName
      flags.push '--grep'
      flags.push @testName

    opts =
      cwd: @context.root
      env: process.env

    mocha = spawn @context.mocha, flags, opts
    mocha.stdout.on 'data', (data) => @emit 'output', data.toString()
    mocha.stderr.on 'data', (data) => @emit 'output', data.toString()

    mocha.on 'exit', (code) =>
      if code is 0
        @emit 'success'
      else
        @emit 'failure'
