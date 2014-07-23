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

    node  = atom.config.get 'mocha-test-runner.nodeBinaryPath'
    mocha = spawn node, flags, opts

    mocha.stdout.on 'data', (data) => @emit 'output', data.toString()
    mocha.stderr.on 'data', (data) => @emit 'output', data.toString()

    mocha.on 'error', (err) => @emit 'error', err
    mocha.on 'exit', (code) =>
      if code is 0
        @emit 'success'
      else
        @emit 'failure'
