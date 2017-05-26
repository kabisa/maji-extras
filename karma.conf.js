'use strict';

module.exports = function(karma) {
  karma.set({

    frameworks: [ 'mocha', 'sinon-chai', 'browserify', 'chai-jquery', 'chai-as-promised' ],

    files: [
      { pattern: 'spec/**/*.spec.js', watched: false, included: true, served: true }
    ],

    client: {
      captureConsole: true,
      mocha: {
        reporter: 'html' // view on http://localhost:9876/debug.html
      }
    },

    reporters: ['mocha'],
    browsers: [ 'PhantomJS' ],
  });
};
