fs     = require 'fs'
path   = require 'path'
util   = require 'util'
events = require 'events'
escape = require 'jsesc'
ansi   = require 'ansi-html-stream'
psTree = require 'ps-tree'
spawn  = require('child_process').spawn

clickablePaths = require './clickable-paths'

STATS_MATCHER = /\d+\s+(?:failing|passing|pending)/g

module.exports = class MochaWrapper extends events.EventEmitter

  constructor: (@context, debugMode = false) ->
    @mocha = null
    @node = atom.config.get 'mocha-test-runner.nodeBinaryPath'
    @textOnly = atom.config.get 'mocha-test-runner.textOnlyOutput'
    @options = atom.config.get 'mocha-test-runner.options'

    if debugMode
      optionsForDebug = atom.config.get 'mocha-test-runner.optionsForDebug'
      @options = "#{@options} #{optionsForDebug}"

    @resetStatistics()

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

    @resetStatistics()
    @mocha = spawn @context.mocha, flags, opts

    if @textOnly
      @mocha.stdout.on 'data', (data) => @emit 'output', data.toString()
      @mocha.stderr.on 'data', (data) => @emit 'output', data.toString()
    else
      stream = ansi(chunked: false)
      @mocha.stdout.pipe stream
      @mocha.stderr.pipe stream
      stream.on 'data', (data) =>
        @parseStatistics data
        @emit 'output', clickablePaths.link data.toString()

    @mocha.on 'error', (err) =>
      @emit 'error', err

    @mocha.on 'exit', (code) =>
      if code is 0
        @emit 'success', @stats
      else
        @emit 'failure', @stats

  resetStatistics: ->
    @stats = []

  parseStatistics: (data) ->
    while matches = STATS_MATCHER.exec(data)
      stat = matches[0]
      @stats.push(stat)
      @emit 'updateSummary', @stats


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
