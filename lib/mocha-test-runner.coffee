path = require 'path'
createPane = require 'atom-pane'
selectedTest = require './selected-test'
MochaWrapper = require './mocha-wrapper'

module.exports =

  activate: (state) ->
    atom.workspaceView.command "mocha-test-runner:run", => @run()

  deactivate: ->

  serialize: ->

  run: ->

    editor = atom.workspaceView.getActivePaneItem()
    test = selectedTest.fromEditor editor

    results = document.createElement 'pre'
    results.innerHTML = ''
    results.classList.add 'results'

    create = (err, pane) ->

      if err then throw err
      pane[0].classList.add 'mocha-test-runner'
      pane.append results

      wrapper = new MochaWrapper editor.getPath(), test
      wrapper.on 'output', (text) -> results.innerHTML += text
      wrapper.on 'error',   (err) -> results.innerHTML += 'Failed to run the test: ' + err
      wrapper.on 'success', -> results.classList.add 'success'
      wrapper.on 'failure', -> results.classList.add 'failure'
      wrapper.run()

    closed = ->
      results.parentNode.removeChild results

    createPane paneOptions(editor), create, closed

paneOptions = (editor) ->
  searchAllPanes: true
  changeFocus: false
  uri: 'mocha-test-runner://' + editor.getPath()
  title: 'Mocha: ' + path.basename(editor.getPath())
  split: 'right'
