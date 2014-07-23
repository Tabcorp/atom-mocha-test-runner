path = require 'path'
createPane = require 'atom-pane'
context = require './context'
selectedTest = require './selected-test'
MochaWrapper = require './mocha-wrapper'
ResultView = require './result-view'

resultView = null

module.exports =

  activate: (state) ->
    atom.workspaceView.command "mocha-test-runner:run", => @run()
    resultView = new ResultView(state)

  deactivate: ->
    resultView.detach()
    resultView = null

  serialize: ->
    resultView.serialize()

  run: ->

    resultView.reset()
    if not resultView.hasParent()
      atom.workspaceView.prependToBottom resultView

    editor   = atom.workspaceView.getActivePaneItem()
    ctx      = context.find editor.getPath()
    testName = selectedTest.fromEditor editor
    wrapper  = new MochaWrapper ctx, testName

    wrapper.on 'error',   (err) ->
      resultView.addLine('Failed to run the test: ' + err)
      resultView.failed()
    wrapper.on 'output', (text) -> resultView.addLine(text)
    wrapper.on 'success', -> resultView.success()
    wrapper.on 'failure', -> resultView.failed()

    wrapper.run()
