module.exports =
  addSwipeSupport: ($el) ->
    view = this
    $el.each ->
      @addEventListener(
        'touchstart'
        (e) ->
          view._swipeData =
            inSwipe: yes
            start: [e.touches[0].pageX, e.touches[0].pageY]
            target: this
            distance: [0, 0]
            direction: [0, 0]
            startAt: 1 * new Date
            updatedAt: 1 * new Date
          view.trigger('swipe:start', view, view._swipeData)
        no
      )
      @addEventListener(
        'touchmove'
        (e) ->
          current = [e.touches[0].pageX, e.touches[0].pageY]

          newDistance = [
            current[0] - view._swipeData.start[0]
            current[1] - view._swipeData.start[1]
          ]
          view._swipeData.direction = [
            newDistance[0] - view._swipeData.distance[0]
            newDistance[1] - view._swipeData.distance[1]
          ]
          view._swipeData.distance = newDistance
          view._swipeData.updatedAt = 1 * new Date
          view.trigger('swipe:update', view, view._swipeData)
        no
      )
      @addEventListener(
        'touchend'
        (e) ->
          view._swipeData.updatedAt = 1 * new Date
          view._swipeData.inSwipe = no
          view.trigger('swipe:end', view, view._swipeData)
          view._swipeData = null
        no
      )
      @addEventListener(
        'touchcancel'
        (e) ->
          view._swipeData.updatedAt = 1 * new Date
          view._swipeData.inSwipe = no
          view.trigger('swipe:cancel', view, view._swipeData)
          view._swipeData = null
        no
      )
