"use strict";
const buble = require("rollup-plugin-buble");

module.exports = function (config) {
  config.set({
    frameworks: [ "mocha", "chai" ],
    preprocessors: {
      "spec/**/*.js": ["rollup"]
    },
    rollupPreprocessor: {
      // rollup settings. See Rollup documentation
      plugins: [
        buble() // ES2015 compiler by the same author as Rollup
      ],
      // will help to prevent conflicts between different tests entries
      format: "es"
    },

    files: [
      { pattern: "spec/**/*.spec.js", watched: true, included: true, served: true }
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
