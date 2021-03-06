(function() {
  module.exports = {
    addSwipeSupport: function($el) {
      var view;
      view = this;
      return $el.each(function() {
        this.addEventListener('touchstart', function(e) {
          view._swipeData = {
            inSwipe: true,
            start: [e.touches[0].pageX, e.touches[0].pageY],
            target: this,
            distance: [0, 0],
            direction: [0, 0],
            startAt: 1 * new Date,
            updatedAt: 1 * new Date
          };
          return view.trigger('swipe:start', view, view._swipeData);
        }, false);
        this.addEventListener('touchmove', function(e) {
          var current, newDistance;
          current = [e.touches[0].pageX, e.touches[0].pageY];
          newDistance = [current[0] - view._swipeData.start[0], current[1] - view._swipeData.start[1]];
          view._swipeData.direction = [newDistance[0] - view._swipeData.distance[0], newDistance[1] - view._swipeData.distance[1]];
          view._swipeData.distance = newDistance;
          view._swipeData.updatedAt = 1 * new Date;
          return view.trigger('swipe:update', view, view._swipeData);
        }, false);
        this.addEventListener('touchend', function(e) {
          view._swipeData.updatedAt = 1 * new Date;
          view._swipeData.inSwipe = false;
          view.trigger('swipe:end', view, view._swipeData);
          return view._swipeData = null;
        }, false);
        return this.addEventListener('touchcancel', function(e) {
          view._swipeData.updatedAt = 1 * new Date;
          view._swipeData.inSwipe = false;
          view.trigger('swipe:cancel', view, view._swipeData);
          return view._swipeData = null;
        }, false);
      });
    }
  };

}).call(this);
