# Contributing

Maji Extras should only contain components that are extracted from real
in-use projects, that are tested in the field.

The addition should be general purpose, so that other projects can use
its value without needing to change it. The base setup assumed for these
components is the latest Maji version.

The components should add as little extra dependencies to the project as
possible, unless the component is a direct usage of that dependency.
(e.g. local forage drivers depending on local forage)

Currenty we have the following categories to contribute to:

- Factories. Using the `js-factories` npm lib, the factories should be
  general purpose (backbone/marionette/cordova) and never be domain
  specific.
- Components. These should be stand alone instances in your app.
- Helpers. These should be embedded within other component within your
  app (like views or models)

If your contribution does not fall into any of these categories, please
raise an issue that we need another type
