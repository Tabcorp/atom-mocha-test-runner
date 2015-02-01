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
    height = state?.height
    @openHeight = Math.max(140,state?.openHeight,height)
    @height height

    @heading.on 'dblclick', => @toggleCollapse()
    @closeButton.on 'click', => atom.commands.dispatch this, 'result-view:close'
    @resizeHandle.on 'mousedown', (e) => @resizeStarted e
    @results.addClass 'native-key-bindings'
    @results.attr 'tabindex', -1

    clickablePaths.attachClickHandler()

  serialize: ->
    height: @height()
    openHeight: @openHeight

  destroy: ->
    clickablePaths.removeClickHandler()

  resizeStarted: ({pageY}) ->
    @resizeData =
      pageY: pageY
      height: @height()
    $(document.body).on 'mousemove', @resizeView
    $(document.body).one 'mouseup', @resizeStopped.bind(this)

  resizeStopped: ->
    $(document.body).off 'mousemove', @resizeView

    currentHeight = @height()
    if currentHeight > @heading.outerHeight()
      @openHeight = currentHeight

  resizeView: ({pageY}) =>
    headingHeight =  @heading.outerHeight()
    @height Math.max(@resizeData.height + @resizeData.pageY - pageY,headingHeight)

  reset: ->
    @heading.removeClass 'alert-success alert-danger'
    @heading.addClass 'alert-info'
    @headingText.html "#{DEFAULT_HEADING_TEXT}..."
    @results.empty()

  addLine: (line) ->
    if line isnt '\n'
      @results.append line

  success: (stats) ->
    @heading.removeClass 'alert-info'
    @heading.addClass 'alert-success'

  failure: (stats) ->
    @heading.removeClass 'alert-info'
    @heading.addClass 'alert-danger'

  updateSummary: (stats) ->
    return unless stats?.length
    @headingText.html "#{DEFAULT_HEADING_TEXT}: #{stats.join(', ')}"

  toggleCollapse: ->
    headingHeight = @heading.outerHeight()
    viewHeight = @height()

    return unless headingHeight > 0

    if viewHeight > headingHeight
      @openHeight = viewHeight
      @height(headingHeight)
    else
      @height @openHeight
