(function() {
  var Infector;

  Infector = (function() {
    function Infector() {}

    Infector.prototype.aliasMethodChain = function(klass, method, feature) {
      var base, base1, name, withFeature, withoutFeature;
      if ((base = klass.prototype).__infected == null) {
        base.__infected = [];
      }
      if (klass.prototype.__infected.indexOf(method) === -1) {
        klass.prototype.__infected.push(method);
      }
      if ((base1 = klass.prototype)[name = "__original_" + method] == null) {
        base1[name] = klass.prototype[method];
      }
      if (klass.desinfect == null) {
        klass.desinfect = function() {
          var i, len, ref, results;
          ref = this.prototype.__infected;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            method = ref[i];
            results.push(this.prototype[method] = this.prototype["__original_" + method]);
          }
          return results;
        };
      }
      withoutFeature = klass.prototype[method];
      withFeature = klass.prototype[method + "With" + feature];
      if (withFeature && withoutFeature) {
        klass.prototype[method + "Without" + feature] = withoutFeature;
        return klass.prototype[method] = withFeature;
      }
    };

    return Infector;

  })();

  module.exports = Infector;

}).call(this);
