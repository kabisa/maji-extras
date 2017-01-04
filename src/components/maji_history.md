# MajiHistory

The MajiHistory is an extended version of the [Backbone.History][bbhist]. It emits events when routing is done, and emits also events to the router when the browser leaves a route.

[bbhist]: http://backbonejs.org/#History

## Install

`npm i maji-extras --save`

in `app.coffee`

```coffee
MajiHistory = require('maji-extras/lib/maji_history')
Backbone.history = new MajiHistory
```

## Usage

detecting leaving a route:

```coffee
class MyRouter extends Marionette.AppRouter
  routes:
    'someRoute': 'myAction'
    
  initialize: ->
    @on 'leaveRoute:myAction', ->
      # Stuff to do when user navigates away
```
