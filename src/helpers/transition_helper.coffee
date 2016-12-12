$ = require('jquery')
_ = require('underscore')

class TransitionHelper

  initializeTransitions: ->
    @noTransitions = !@_transitionEventName()

  constructor: (@$el) ->

  removeClass: (className, $el = @$el) ->
    p = @_transitionPromise($el)
    @delay ->
      p.start()
      $el.removeClass className
    .then ->
      p.promise

  addClass: (className, $el = @$el) ->
    p = @_transitionPromise($el)
    @delay ->
      p.start()
      $el.addClass className
    .then ->
      p.promise

  css: (css, $el = @$el) ->
    p = @_transitionPromise($el)
    @delay ->
      p.start()
      $el.css css
    .then ->
      p.promise

  delay: (code, time = 0) ->
    if @noTransitions
      result = code()
      return $.Deferered().resolve(result)

    defer = $.Deferred()
    setTimeout(
      -> $.when(code()).then (result) -> defer.resolve(result)
      time
    )
    defer.promise()

  _transitionPromise: ($el) ->
    defer = $.Deferred()
    noTransitions = @noTransitions
    transition =
      duration: @_getTransitionDuration($el)
      eventName: @_transitionEventName()
      properties: @_getTransitionProperties($el)
      resolver: defer
      el: $el[0]
      view: this
      handler: ->
        clearTimeout(@timeout)
        @el.removeEventListener(@eventName, @handler, false)
        @resolver.resolve(this)
      start: ->
        return @resolver.resolve(this) if noTransitions or _.isNaN(@duration)
        @timeout = setTimeout(
          @handler
          @duration
        )
        startTime = 1 * new Date
        @el.addEventListener(@eventName, (e) =>
          currentDuration = (1 * new Date) - startTime
          diff = Math.abs(@duration - currentDuration)
          if e.pseudoElement is '' and diff < 10
            @handler()
        , false)
      promise: defer.promise()
    _.bindAll(transition, 'handler', 'start')

    transition

  _getTransitionDuration: ($el) ->
    duration = @_parseTime $el.css('transitionDuration')
    delay = @_parseTime $el.css('transitionDelay')
    (duration + delay) * 1000

  _getTransitionProperties: ($el) ->
    $el.css('transitionProperty')

  _parseTime: (text) ->
    Math.max (parseFloat(item) for item in text.split(', '))...

  _transitionEventName: ->
    el = document.createElement('fakeelement')
    transitions =
      'transition': 'transitionend'
      'OTransition': 'oTransitionEnd'
      'MozTransition': 'transitionend'
      'WebkitTransition': 'webkitTransitionEnd'
    return event for property, event of transitions when el.style[property]?

module.exports = TransitionHelper
