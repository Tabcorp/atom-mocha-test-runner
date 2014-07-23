path        = require 'path'
context     = require './context'
Mocha       = require './mocha'
ResultView  = require './result-view'

resultView = null
currentContext = null

module.exports =

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

    editor   = atom.workspaceView.getActivePaneItem()
    mocha  = new Mocha currentContext

    mocha.on 'success', -> resultView.success()
    mocha.on 'failure', -> resultView.failed()
    mocha.on 'output', (text) -> resultView.addLine(text)
    mocha.on 'error', (err) ->
      resultView.addLine('Failed to run Mocha\n' + err.message)
      resultView.failed()

    mocha.run()
