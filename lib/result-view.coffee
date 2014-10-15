{$, $$$, View} = require 'atom'

module.exports =
class ResultView extends View

  @content: ->
    @div class: 'mocha-test-runner', =>
      @div outlet: 'resizeHandle', class: 'resize-handle'
      @div class: 'panel', =>
        @div outlet: 'heading', class: 'heading', =>
          @div class: 'pull-right', =>
            @span outlet: 'closeButton', class: 'close-icon'
          @span 'Mocha test results'
        @div class: 'panel-body', =>
          @pre outlet: 'results', class: 'results'

  initialize: (state) ->
    @height state?.height
    @closeButton.on 'click', => @trigger 'result-view:close'
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
    @heading.removeClass 'alert-success alert-danger'
    @results.empty()

  addLine: (line) ->
    if line isnt '\n'
      @results.append line

  success: ->
    @heading.addClass 'alert-success'

  failure: ->
    @heading.addClass 'alert-danger'
