(function() {
  var Factory;

  Factory = require('js-factories');

  Factory.define('cordovaCamera', function() {
    var camera;
    camera = {
      fakeBase64Picture: 'iVBORw0KGgoAAAANSUhEUgAAAAUA' + 'AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO' + '9TXL0Y4OHwAAAABJRU5ErkJggg==',
      fakePictureURL: 'content://media/external/images/media/2',
      fakeErrorMessage: 'Camera is broken',
      respondWith: 'success',
      getPicture: function(success, error, options) {
        var data;
        data = this.fakePictureURL;
        if (options.destinationType === 0) {
          data = this.fakeBase64Picture;
        }
        return setTimeout((function(_this) {
          return function() {
            if (_this.respondWith === 'success') {
              success(data);
            }
            if (_this.respondWith === 'error') {
              return error(_this.fakeErrorMessage);
            }
          };
        })(this), 2);
      },
      attach: function() {
        var nav;
        window.Camera = {
          DestinationType: {
            DATA_URL: 0,
            FILE_URI: 1,
            NATIVE_URI: 2
          },
          EncodingType: {
            JPEG: 0,
            PNG: 1
          },
          MediaType: {
            PICTURE: 0,
            VIDEO: 1,
            ALLMEDIA: 2
          },
          PictureSourceType: {
            PHOTOLIBRARY: 0,
            CAMERA: 1,
            SAVEDPHOTOALBUM: 2
          },
          PopoverArrowDirection: {
            ARROW_UP: 1,
            ARROW_DOWN: 2,
            ARROW_LEFT: 4,
            ARROW_RIGHT: 8,
            ARROW_ANY: 15
          },
          Direction: {
            BACK: 0,
            FRONT: 1
          }
        };
        nav = window.navigator != null ? window.navigator : window.navigator = {};
        nav.camera = camera;
        return camera;
      },
      restore: function() {
        delete window.Camera;
        delete window.navigator.camera;
        return this.getPicture.reset();
      }
    };
    sinon.spy(camera, 'getPicture');
    return camera;
  });

}).call(this);
