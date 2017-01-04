# Helpers

Helpers are common utilities to use in your app.
They are there to solve common problems, or implement common interfaces.
They are meant to enrich a component within your app, and not be a stand
alone instance within your app.

inclusion:

```coffee
Helper = require('maji-extras/lib/helpers/<helper-name>')
```

- [infector](./infector.md) -- Create chaining constructions for mixins
- [transitionHelper](./transition_helper.md) -- Wait on CSS transitions
  using a promise
