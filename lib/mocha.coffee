fs     = require 'fs'
path   = require 'path'
util   = require 'util'
events = require 'events'
escape = require 'jsesc'
ansi   = require 'ansi-html-stream'
psTree = require 'ps-tree'
spawn  = require('child_process').spawn

module.exports = class MochaWrapper extends events.EventEmitter

  constructor: (@context, debugMode = false) ->
    @mocha = null
    @node = atom.config.get 'mocha-test-runner.nodeBinaryPath'
    @textOnly = atom.config.get 'mocha-test-runner.textOnlyOutput'
    @options = atom.config.get 'mocha-test-runner.options'

    if debugMode
      optionsForDebug = atom.config.get 'mocha-test-runner.optionsForDebug'
      @options = "#{@options} #{optionsForDebug}"

  stop: ->
    if @mocha?
      killTree(@mocha.pid)
      @mocha = null

  run: ->

    flags = [
      @context.test
    ]

    if @textOnly
      flags.push '--no-colors'

    if @context.grep
      flags.push '--grep'
      flags.push escape(@context.grep, escapeEverything: true)

    if @options
      Array::push.apply flags, @options.split ' '

    opts =
      cwd: @context.root
      env: { PATH: path.dirname(@node) }

    @mocha = spawn @context.mocha, flags, opts

    if @textOnly
      @mocha.stdout.on 'data', (data) => @emit 'output', data.toString()
      @mocha.stderr.on 'data', (data) => @emit 'output', data.toString()
    else
      stream = ansi(chunked: false)
      @mocha.stdout.pipe stream
      @mocha.stderr.pipe stream
      stream.on 'data', (data) => @emit 'output', data.toString()

    @mocha.on 'error', (err) =>
      @emit 'error', err

    @mocha.on 'exit', (code) =>
      if code is 0
        @emit 'success'
      else
        @emit 'failure'


killTree = (pid, signal, callback) ->
  signal = signal or 'SIGKILL'
  callback = callback or (->)
  psTree pid, (err, children) ->
    childrenPid = children.map (p) -> p.PID
    [pid].concat(childrenPid).forEach (tpid) ->
      try
        process.kill tpid, signal
      catch ex
        console.log "Failed to #{signal} #{tpid}"
    callback()
