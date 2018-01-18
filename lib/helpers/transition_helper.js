(function() {
  var $, TransitionHelper, _;

  $ = require('jquery');

  _ = require('underscore');

  TransitionHelper = (function() {
    TransitionHelper.prototype.initializeTransitions = function() {
      return this.noTransitions = !this._transitionEventName();
    };

    function TransitionHelper($el1) {
      this.$el = $el1;
    }

    TransitionHelper.prototype.removeClass = function(className, $el) {
      var p;
      if ($el == null) {
        $el = this.$el;
      }
      p = this._transitionPromise($el);
      return this.delay(function() {
        p.start();
        return $el.removeClass(className);
      }).then(function() {
        return p.promise;
      });
    };

    TransitionHelper.prototype.addClass = function(className, $el) {
      var p;
      if ($el == null) {
        $el = this.$el;
      }
      p = this._transitionPromise($el);
      return this.delay(function() {
        p.start();
        return $el.addClass(className);
      }).then(function() {
        return p.promise;
      });
    };

    TransitionHelper.prototype.css = function(css, $el) {
      var p;
      if ($el == null) {
        $el = this.$el;
      }
      p = this._transitionPromise($el);
      return this.delay(function() {
        p.start();
        return $el.css(css);
      }).then(function() {
        return p.promise;
      });
    };

    TransitionHelper.prototype.delay = function(code, time) {
      var defer, result;
      if (time == null) {
        time = 0;
      }
      if (this.noTransitions) {
        result = code();
        return $.Deferered().resolve(result);
      }
      defer = $.Deferred();
      setTimeout(function() {
        return $.when(code()).then(function(result) {
          return defer.resolve(result);
        });
      }, time);
      return defer.promise();
    };

    TransitionHelper.prototype._transitionPromise = function($el) {
      var defer, noTransitions, transition;
      defer = $.Deferred();
      noTransitions = this.noTransitions;
      transition = {
        duration: this._getTransitionDuration($el),
        eventName: this._transitionEventName(),
        properties: this._getTransitionProperties($el),
        resolver: defer,
        el: $el[0],
        view: this,
        handler: function() {
          clearTimeout(this.timeout);
          this.el.removeEventListener(this.eventName, this.handler, false);
          return this.resolver.resolve(this);
        },
        start: function() {
          var startTime;
          if (noTransitions || _.isNaN(this.duration)) {
            return this.resolver.resolve(this);
          }
          this.timeout = setTimeout(this.handler, this.duration);
          startTime = 1 * new Date;
          return this.el.addEventListener(this.eventName, (function(_this) {
            return function(e) {
              var currentDuration, diff;
              currentDuration = (1 * new Date) - startTime;
              diff = Math.abs(_this.duration - currentDuration);
              if (e.pseudoElement === '' && diff < 10) {
                return _this.handler();
              }
            };
          })(this), false);
        },
        promise: defer.promise()
      };
      _.bindAll(transition, 'handler', 'start');
      return transition;
    };

    TransitionHelper.prototype._getTransitionDuration = function($el) {
      var delay, duration;
      duration = this._parseTime($el.css('transitionDuration'));
      delay = this._parseTime($el.css('transitionDelay'));
      return (duration + delay) * 1000;
    };

    TransitionHelper.prototype._getTransitionProperties = function($el) {
      return $el.css('transitionProperty');
    };

    TransitionHelper.prototype._parseTime = function(text) {
      var item;
      return Math.max.apply(Math, (function() {
        var i, len, ref, results;
        ref = text.split(', ');
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          item = ref[i];
          results.push(parseFloat(item));
        }
        return results;
      })());
    };

    TransitionHelper.prototype._transitionEventName = function() {
      var el, event, property, transitions;
      el = document.createElement('fakeelement');
      transitions = {
        'transition': 'transitionend',
        'OTransition': 'oTransitionEnd',
        'MozTransition': 'transitionend',
        'WebkitTransition': 'webkitTransitionEnd'
      };
      for (property in transitions) {
        event = transitions[property];
        if (el.style[property] != null) {
          return event;
        }
      }
    };

    return TransitionHelper;

  })();

  module.exports = TransitionHelper;

}).call(this);
