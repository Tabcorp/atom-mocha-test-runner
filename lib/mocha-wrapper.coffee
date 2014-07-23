fs     = require 'fs'
path   = require 'path'
util   = require 'util'
events = require 'events'
spawn  = require('child_process').spawn

module.exports = class MochaWrapper extends events.EventEmitter

  constructor: (@context, @testName) ->

  run: ->

    console.debug 'Root folder:', @context.root
    console.debug 'Test file:', @context.test
    console.debug 'Selected test:', @testName or '<all>'

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
