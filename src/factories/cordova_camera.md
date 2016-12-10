# Cordova Camera Factory

Allows for simulation of the [Cordova Camera plugin][camera] in tests

## Install

`npm i maji-extras --save-dev`

## Usage

Setup for spec

```coffee
Factory = require('js-factories')
require('factories/cordova_camera')

describe 'Some implementation using the camera', ->
  beforeEach ->
    # This will create a navigator.camera like cordova does
    @camera = Factory.create('cordovaCamera').attach()

  afterEach ->
    # Clean up the globals
    @camera.restore()

```

The factory by default spies on `getPicture()` calls
so in the test verification if options for `getPicture()` are correct,
you can use the [sinon-chai] matchers.

```coffee
expect(@camera.getPicture).to.have.been.calledWith(
  sinon.match.typeOf('function') # Success callback
  sinon.match.typeOf('function') # Error callback
  sinon.match( # Supplied options
    cameraDirection: Camera.Direction.FRONT
    sourceType: Camera.PictureSourceType.CAMERA
  )
)
```

### Simulating camera responses

By default it returns a picture url as defined in `@camera.fakePictureURL`. If the

```coffee
destinationType: Camera.DestinationType.DATA_URL
```

option is provided, the return will be the value defined in `@camera.fakeBase64Picture`

Both values can be set by the test as well.

To test the error callback, you can set `@camera.respondWith = 'error'`.
The factory will then call the error callback set with the value defined in `@camera.fakeErrorMessage`.

[camera]: https://github.com/apache/cordova-plugin-camera
[sinon-chai]: https://github.com/domenic/sinon-chai
