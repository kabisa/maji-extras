(function() {
  var Backbone, MajiHistory, _,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Backbone = require('backbone');

  _ = require('underscore');

  MajiHistory = (function(superClass) {
    extend(MajiHistory, superClass);

    MajiHistory.prototype.activeRoute = {
      router: null,
      action: null
    };

    function MajiHistory() {
      MajiHistory.__super__.constructor.apply(this, arguments);
      this.on('route', this._updateActiveRoute, this);
    }

    MajiHistory.prototype.loadUrl = function(fragmentOverride) {
      var fragment, result;
      fragment = this.getFragment(fragmentOverride);
      this.trigger('loadingUrl', fragment);
      this._fireLeaveRoute();
      result = MajiHistory.__super__.loadUrl.apply(this, arguments);
      if (!result) {
        this.trigger('routeNotFound', fragment);
      }
      return result;
    };

    MajiHistory.prototype.getFragment = function() {
      var s;
      s = MajiHistory.__super__.getFragment.apply(this, arguments);
      return this.stripQuery(s);
    };

    MajiHistory.prototype.stripQuery = function(fragment) {
      var query, ref, route;
      if (!_.contains(fragment, '?')) {
        return fragment;
      }
      ref = fragment.split('?'), route = ref[0], query = ref[1];
      return route;
    };

    MajiHistory.prototype._updateActiveRoute = function(router, action) {
      return this.activeRoute = {
        router: router,
        action: action
      };
    };

    MajiHistory.prototype._fireLeaveRoute = function() {
      if (this.activeRoute.router != null) {
        this.activeRoute.router.trigger("leaveRoute:" + this.activeRoute.action, this.activeRoute.router);
      }
      this.activeRoute.router = null;
      return this.activeRoute.action = null;
    };

    MajiHistory.prototype.hashQuery = function() {
      var hash, i, key, keyValue, keyValues, len, query, ref, ref1, result, route, value;
      hash = window.location.hash;
      result = {};
      if (_.contains(hash, '?')) {
        ref = hash.split('?'), route = ref[0], query = ref[1];
        keyValues = query.split('&');
        for (i = 0, len = keyValues.length; i < len; i++) {
          keyValue = keyValues[i];
          ref1 = keyValue.split('='), key = ref1[0], value = ref1[1];
          result[key] = value;
        }
      }
      return result;
    };

    return MajiHistory;

  })(Backbone.History);

  module.exports = MajiHistory;

}).call(this);
