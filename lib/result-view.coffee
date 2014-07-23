{$, $$$, View} = require 'atom'

module.exports =
class ResultView extends View

  @content: ->
    @div class: 'mocha-test-runner', =>
      @div outlet: 'resizeHandle', class: 'resize-handle'
      @div class: "panel", =>
        @div class: "panel-heading", =>
          @div class: 'pull-right', =>
            @span outlet: 'closeButton', class: 'close-icon'
          @span 'Test results'
        @div class: 'panel-body', =>
          @pre outlet: 'results', class: 'results'

  initialize: (state) ->
    @height state?.height
    @closeButton.on 'click', => @detach()
    @resizeHandle.on 'mousedown', (e) => @resizeStarted e

  serialize: ->
    height: @height()

  resizeStarted: ({pageY}) ->
    @resizeData =
      pageY: pageY
      height: @height()
    $(document.body).on 'mousemove', @resizeView
    $(document.body).on 'mouseup', @resizeStopped

  resizeStopped: ->
    $(document.body).off 'mousemove', @resizeView
    $(document.body).off 'mouseup', @resizeStopped

  resizeView: ({pageY}) =>
    @height @resizeData.height + @resizeData.pageY - pageY

  reset: ->
    @results.removeClass 'success failure'
    @results.empty()

  addLine: (line) ->
    # line = line.replace(/^  /, '').replace(/^\n/, '')
    if line isnt '\n'
      @results.append line

  success: ->
    @results.addClass 'success'

  failed: ->
    @results.addClass 'failure'
