# Infector

Allow mixins in classes that use `aliasMethodChain` to replace methods.

Useful for adding multiple mixins to a class that want to alter the
behavior of the same method.

## Install

`npm i maji-extras --save`

`Infector = require('maji-extras/lib/helpers/infector')`

## Why an infector

Let's say you have a mixin to add offline support to your Backbone
Models. But it required altering the `.sync` method.

But you also want to alter the `.sync` method to provide default
credentials on each request to the backend.

With inheritance that would require:

```coffee
class MyModel extends OfflineModel

class OfflineModel extends CredentialModel
  # ^^ this is what you don't want

  sync: (verb, model, options) ->
    # do offline magic
    super

class CredentialModel extends Backbone.model
  sync: (verb, model, options) ->
    # add credentials to provided options
    options.password = 'supersecretneverguess'
    super

```

that doesn't seem right...

With mixins it would look like this

```coffee
class MyModel extends Backbone.Model

_.extend(MyModel::,
  sync: (verb, model, options) ->
    # No access to `super`
    # so we need to re-implement the original implementation

    # add credentials to provided options
    options.password = 'supersecretneverguess'
    Backbone.sync(verb, model, options)
)
```

With infectors it would look like this:

## Example

```coffee
class OfflineInfector extends Infector
  infectModel: (modelClass) ->
    _.extend(modelClass::,
      syncWithOffline: (verb, model, options) ->
        # do offline magic
        @syncWithoutOffline(verb, model, options)

      otherMethodsWeLikeToAdd: ->
    )
    @aliasMethodChain(modelClass, 'sync', 'Offline')

class CredentialInfector extends Infector
  infectModel: (modelClass) ->
    _.extend(modelClass::,
      syncWithCredentials: (verb, model, options) ->
        # add credentials to provided options
        options.password = 'supersecretneverguess'
        @syncWithoutCredentials(verb, model, options)
    )
    @aliasMethodChain(modelClass, 'sync', 'Credentials')

class MyModel extends Backbone.Model

(new OfflineInfector).infectModel(MyModel)
(new CredentialInfector).infectModel(MyModel)
```

