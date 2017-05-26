"use strict";

module.exports = function (config) {
  config.set({
    frameworks: [ "mocha", "chai" ],
    preprocessors: {
      'src/**/*.js': ['rollup'],
      "spec/**/*.js": ["rollup"]
    },
    rollupPreprocessor: {
      // rollup settings. See Rollup documentation
      plugins: [
        require("rollup-plugin-buble")(),
        require("rollup-plugin-node-resolve")(),
        require("rollup-plugin-commonjs")()
      ],
      // will help to prevent conflicts between different tests entries
      format: "es"
    },

    files: [
      { pattern: 'src/**/*.js', included: false },
      'spec/**/*.spec.js'
    ],
    client: {
      captureConsole: true,
      mocha: {
        reporter: "html" // view on http://localhost:9876/debug.html
      }
    },

    reporters: ["mocha"],
    browsers: [ "PhantomJS" ]

  });
};
