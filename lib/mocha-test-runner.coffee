path        = require 'path'
createPane  = require 'atom-pane'
context     = require './context'
Mocha       = require './mocha'
ResultView  = require './result-view'

resultView = null
currentContext = null

module.exports =

  activate: (state) ->
    atom.workspaceView.command "mocha-test-runner:run", => @run()
    atom.workspaceView.command "mocha-test-runner:run-previous", => @runPrevious()
    resultView = new ResultView(state)

  deactivate: ->
    resultView.detach()
    resultView = null

  serialize: ->
    resultView.serialize()

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

    editor   = atom.workspaceView.getActivePaneItem()
    mocha  = new Mocha currentContext

    mocha.on 'success', -> resultView.success()
    mocha.on 'failure', -> resultView.failed()
    mocha.on 'output', (text) -> resultView.addLine(text)
    mocha.on 'error', (err) ->
      resultView.addLine('Failed to run the test: ' + err)
      resultView.failed()

    mocha.run()
