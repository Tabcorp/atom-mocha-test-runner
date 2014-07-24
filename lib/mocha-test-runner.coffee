path        = require 'path'
context     = require './context'
Mocha       = require './mocha'
ResultView  = require './result-view'

resultView = null
currentContext = null

module.exports =

  configDefaults:
    nodeBinaryPath: '/usr/local/bin/node'
    textOnlyOutput: false
    showDebugInformation: false

  activate: (state) ->
    atom.workspaceView.on 'core:cancel', => @close()
    atom.workspaceView.on 'core:close', => @close()
    atom.workspaceView.command "mocha-test-runner:run", => @run()
    atom.workspaceView.command "mocha-test-runner:run-previous", => @runPrevious()
    resultView = new ResultView(state)

  deactivate: ->
    atom.workspaceView.off 'core:cancel core:close'
    resultView.detach()
    resultView = null

  serialize: ->
    resultView.serialize()

  close: ->
    resultView.detach()

  run: ->
    editor   = atom.workspaceView.getActivePaneItem()
    currentContext = context.find editor
    console.log 'context=', currentContext
    @execute()

  runPrevious: ->
    throw new Error('No previous test run') unless currentContext
    @execute()

  execute: ->

    resultView.reset()
    if not resultView.hasParent()
      atom.workspaceView.prependToBottom resultView

    if atom.config.get 'mocha-test-runner.showDebugInformation'
      resultView.addLine "Root folder: #{currentContext.root}\n"
      resultView.addLine "Test file: #{currentContext.test}\n"
      resultView.addLine "Selected test: #{currentContext.grep or '<all>'}\n\n"

    editor = atom.workspaceView.getActivePaneItem()
    mocha  = new Mocha currentContext

    mocha.on 'success', -> resultView.success()
    mocha.on 'failure', -> resultView.failure()
    mocha.on 'output', (text) -> resultView.addLine(text)
    mocha.on 'error', (err) ->
      resultView.addLine('Failed to run Mocha\n' + err.message)
      resultView.failure()

    mocha.run()
