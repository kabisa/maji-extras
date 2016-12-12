# TransitionHelper

Allow to wait on CSS transitions from your view based on promises. This way your front-end code will always be in sync when timings of transitions in the CSS change.

## Install

`npm i maji-extras --save`


## Usage

CSS:

```scss
.fade-close {
  transition: opacity 1s;
  opacity: 1;

  &.closing {
    opacity: 0;
  }
}
```

View:

```coffee
TransitionHelper = require('maji-extras/lib/helpers/transition_helper')

class MyView extends Marionette.View
  className: 'fade-close'

  events:
    'click @ui.delete': 'onDelete'

  initialize: ->
    @tr = new TransitionHelper(@$el)

  onDelete: ->
    @tr.addClass('closing').then =>
      # Resolves when item is fully faded out
      @model.destroy()

```
