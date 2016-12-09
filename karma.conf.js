'use strict';

module.exports = function(karma) {
  karma.set({

    frameworks: [ 'mocha', 'sinon-chai', 'browserify' ],

    files: [
      { pattern: 'test/**/*spec.coffee', watched: false, included: true, served: true }
    ],

    preprocessors: {
      'test/**/*spec.coffee': [ 'browserify' ]
    },

    client: {
      captureConsole: true,
      mocha: {
        reporter: 'html' // view on http://localhost:9876/debug.html
      }
    },

    reporters: ['mocha'],
    browsers: [ 'PhantomJS' ],

    // browserify configuration
    browserify: {
      debug: true,
      extensions: ['.coffee'],
      transform: [ 'coffeeify', 'aliasify', 'yamlify' ]
    }
  });
};
