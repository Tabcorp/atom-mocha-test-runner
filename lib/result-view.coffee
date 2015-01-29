{$, $$$, View} = require 'atom-space-pen-views'
clickablePaths = require './clickable-paths'

DEFAULT_HEADING_TEXT = 'Mocha test results'

module.exports =
class ResultView extends View

  @content: ->
    @div class: 'mocha-test-runner', =>
      @div outlet: 'resizeHandle', class: 'resize-handle'
      @div class: 'panel', =>
        @div outlet: 'heading', class: 'heading', =>
          @div class: 'pull-right', =>
            @span outlet: 'closeButton', class: 'close-icon'
          @span outlet: 'headingText', DEFAULT_HEADING_TEXT
        @div class: 'panel-body', =>
          @pre outlet: 'results', class: 'results'

  initialize: (state) ->
    @height state?.height
    @closeButton.on 'click', => atom.commands.dispatch this, 'result-view:close'
    @resizeHandle.on 'mousedown', (e) => @resizeStarted e
    @results.addClass 'native-key-bindings'
    @results.attr 'tabindex', -1

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
    @heading.addClass 'alert-info'
    @headingText.html "#{DEFAULT_HEADING_TEXT}..."
    @results.empty()

  addLine: (line) ->
    if line isnt '\n'
      @results.append line
      clickablePaths.attachClickHandler()

  success: (stats) ->
    @heading.removeClass 'alert-info'
    @heading.addClass 'alert-success'

  failure: (stats) ->
    @heading.removeClass 'alert-info'
    @heading.addClass 'alert-danger'

  updateSummary: (stats) ->
    return unless stats?.length
    @headingText.html "#{DEFAULT_HEADING_TEXT}: #{stats.join(', ')}"
