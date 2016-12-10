
# This factory simulates the Cordova Camera
#
# ```coffeescript
#
#   @camera = Factory.create('cordovaCamera')
#
#   # Implementation uses navigator.camera like expected
#
#   expect(@camera.getPicture).to.have.been.calledWith(
#     sinon.match.typeOf('function')
#     sinon.match.typeOf('function')
#     sinon.match(
#       cameraDirection: Camera.Direction.FRONT
#       correctOrientation: yes
#       destinationType: Camera.DestinationType.DATA_URL
#     )
#   )
# ```
#
Factory.define('cordovaCamera', ->

  # simulate behaviour of cordova camera
  camera =
    fakeBase64Picture:
      'iVBORw0KGgoAAAANSUhEUgAAAAUA' +
      'AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO' +
      '9TXL0Y4OHwAAAABJRU5ErkJggg=='
    fakePictureURL: 'content://media/external/images/media/2'
    fakeErrorMessage: 'Camera is broken'
    respondWith: 'success'

    getPicture: (success, error, options) ->
      data = @fakePictureURL
      if options.destinationType is 0
        data = @fakeBase64Picture
      setTimeout(
        =>
          success(data) if @respondWith is 'success'
          error(@fakeErrorMessage) if @respondWith is 'error'
        2
      )

    attach: ->
      # https://github.com/apache/cordova-plugin-camera#camera-1
      window.Camera =
        DestinationType:
          DATA_URL: 0
          FILE_URI: 1
          NATIVE_URI: 2
        EncodingType:
          JPEG: 0
          PNG: 1
        MediaType:
          PICTURE: 0
          VIDEO: 1
          ALLMEDIA: 2
        PictureSourceType:
          PHOTOLIBRARY: 0
          CAMERA: 1
          SAVEDPHOTOALBUM: 2
        PopoverArrowDirection:
          ARROW_UP: 1
          ARROW_DOWN: 2
          ARROW_LEFT: 4
          ARROW_RIGHT: 8
          ARROW_ANY: 15
        Direction:
          BACK: 0
          FRONT: 1

      nav = window.navigator ?= {}
      nav.camera = camera
      camera

    restore: ->
      delete window.Camera
      delete window.navigator.camera
      @getPicture.reset()

  sinon.spy(camera, 'getPicture')
  camera
)
