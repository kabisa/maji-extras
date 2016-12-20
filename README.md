# Maji-extras

Useful reusable components to use in the [Maji][maji] framework.

## Installation

`npm i maji-extras --save`

## Usage

You'll never use all of maji-extras, but you pick exactly the parts that you need for your project.

## Development

* Run `npm install` to install all dependencies.
* Run `npm run watch` to start a Karma server with PhantomJS that will continuously watch your JavaScript files and run tests on changes.
* Run `npm test` to run the JavaScript tests and the linter once.
* Run `npm run build` to convert all CoffeeScript file to JavaScript.
* Run `npm run lint` to run the linter.

## Contents

* [helpers](src/helpers/) -- Strong single purpose helpers to perform common tasks
* [components](src/components/) -- Stand alone components for additional
  features
* [factories](src/factories/) -- Common data preparation for usage in tests

[maji]: https://github.com/kabisa/maji

## Versioning

Since we support multiple components that can have their own changes,
its difficult to stick one version number onto this repo.

Because of that, we will stick to the following rules:

* Update of Major when:
  - Directory structure changes
  - File names of components change
* Update of Minor when:
  - New components are added
* Update of Patch when:
  - Components are updated

Components should already be stable before they are added to
Maji-extras. When a component is radically changed and would break the
interface, it should be added as a new component under a different name.

