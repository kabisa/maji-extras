$ = window.jQuery = require('jquery')
_ = require('underscore')

Factory = require('js-factories')
require('factories/cordova_camera')

describe 'CordovaCameraFactory', ->
  beforeEach ->
    @camera = Factory.create('cordovaCamera').attach()

    @implementationThatUsesCamera = (type, extra = {}) ->
      options = switch type
        when 'portrait'
          cameraDirection: Camera.Direction.FRONT
          sourceType: Camera.PictureSourceType.CAMERA
        else
          sourceType: Camera.PictureSourceType.PHOTOLIBRARY

      options = _.extend({}, options, extra)

      d = $.Deferred()
      navigator.camera.getPicture(
        (data) -> d.resolve(data)
        (error) -> d.reject(new Error(error))
        options
      )
      d.promise()

  afterEach ->
    @camera.restore()

  it 'allows inspecting camera calls (1)', ->
    @implementationThatUsesCamera('portrait').always =>
      expect(@camera.getPicture).to.have.been.calledWith(
        sinon.match.typeOf('function')
        sinon.match.typeOf('function')
        sinon.match(
          cameraDirection: Camera.Direction.FRONT
          sourceType: Camera.PictureSourceType.CAMERA
        )
      )

  it 'allows inspecting camera calls (2)', ->
    @implementationThatUsesCamera('other').always =>
      expect(@camera.getPicture).to.have.been.calledWith(
        sinon.match.typeOf('function')
        sinon.match.typeOf('function')
        sinon.match(
          sourceType: Camera.PictureSourceType.PHOTOLIBRARY
        )
      )

  describe 'simulating different datasources', ->

    it 'responds with a fake local url by default', ->
      expect(@implementationThatUsesCamera('other')).to.eventually.equal(@camera.fakePictureURL)

    it 'responds with a fakeBase64 for DestinationType.DATA_URL', ->
      expect(@implementationThatUsesCamera('other',
        destinationType: Camera.DestinationType.DATA_URL)
      ).to.eventually.equal(@camera.fakeBase64Picture)

  describe 'simulation error callback', ->
    it 'can respond with a fake error message', ->
      @camera.fakeErrorMessage = 'Totally broken'
      @camera.respondWith = 'error'
      expect(@implementationThatUsesCamera('other',
        destinationType: Camera.DestinationType.DATA_URL)
      ).to.rejectedWith(Error, 'Totally broken')

