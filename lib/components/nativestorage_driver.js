(function() {
  var $, _addKey, _clear, _getKeys, _initStorage, _iterate, _patchPromise, _removeKey, _return, _setKeys, _support, clear, getItem, iterate, key, keys, length, localforage, nativeStorageDriver, removeItem, setItem;

  $ = require('jquery');

  localforage = require('localforage');

  _support = function() {
    return $.when(typeof window.NativeStorage !== 'undefined');
  };

  _initStorage = function(options) {
    var dbInfo, key, self, value;
    self = this;
    dbInfo = {};
    if (options) {
      for (key in options) {
        value = options[key];
        dbInfo[key] = options[key];
      }
    }
    dbInfo.keyPrefix = dbInfo.name + '/' + dbInfo.storeName + '/';
    dbInfo.dataKeyPrefix = dbInfo.keyPrefix + 'data/';
    dbInfo.metaKeyPrefix = dbInfo.keyPrefix + 'meta/';
    self._dbInfo = dbInfo;
    return localforage.getSerializer().then(function(serializer) {
      dbInfo.serializer = serializer;
      return _getKeys(dbInfo).then(null, function(error) {
        return _setKeys([], dbInfo);
      });
    });
  };

  _patchPromise = function(promise) {
    if (promise["catch"] == null) {
      promise["catch"] = promise.fail;
    }
    return promise;
  };

  _return = function(promise, callback) {
    if (callback) {
      promise.then(function(result) {
        return callback(null, result);
      }, callback);
    }
    return _patchPromise(promise);
  };

  _getKeys = function(dbInfo) {
    var deferred;
    deferred = $.Deferred();
    NativeStorage.getItem(dbInfo.metaKeyPrefix + 'keys', function(serializedKeys) {
      var deserializedKeys;
      deserializedKeys = dbInfo.serializer.deserialize(serializedKeys);
      return deferred.resolve(deserializedKeys);
    }, deferred.reject);
    return _patchPromise(deferred.promise());
  };

  _setKeys = function(keys, dbInfo) {
    var deferred;
    deferred = $.Deferred();
    dbInfo.serializer.serialize(keys, function(serializedKeys, error) {
      if (error) {
        return deferred.reject(error);
      } else {
        return NativeStorage.setItem(dbInfo.metaKeyPrefix + 'keys', serializedKeys, deferred.resolve, deferred.reject);
      }
    });
    return _patchPromise(deferred.promise());
  };

  _addKey = function(key, dbInfo) {
    return _getKeys(dbInfo).then(function(keys) {
      var index;
      index = keys.indexOf(key);
      if (index === -1) {
        keys.push(key);
        return _setKeys(keys, dbInfo);
      }
    });
  };

  _removeKey = function(key, dbInfo) {
    return _getKeys(dbInfo).then(function(keys) {
      var index;
      index = keys.indexOf(key);
      if (index === -1) {
        return;
      }
      keys.splice(index, 1);
      return _setKeys(keys, dbInfo);
    });
  };

  clear = function(callback) {
    var p, self;
    self = this;
    p = self.ready().then(function() {
      var dbInfo;
      dbInfo = self._dbInfo;
      return _getKeys(dbInfo).then(function(keys) {
        return _clear(keys, dbInfo.dataKeyPrefix);
      }).then(function() {
        return _setKeys([], dbInfo);
      });
    });
    return _return(p, callback);
  };

  _clear = function(keys, prefix) {
    var deferred, key;
    deferred = $.Deferred();
    if (keys.length > 0) {
      key = keys[0];
      NativeStorage.remove(prefix + key, function() {
        return _clear(keys.slice(1), prefix).then(deferred.resolve, deferred.reject);
      }, deferred.reject);
    } else {
      deferred.resolve();
    }
    return _patchPromise(deferred.promise());
  };

  getItem = function(key, callback) {
    var deferred, self;
    deferred = $.Deferred();
    self = this;
    self.ready().then(function() {
      var dbInfo;
      dbInfo = self._dbInfo;
      return NativeStorage.getItem(dbInfo.dataKeyPrefix + key, function(value) {
        if (value) {
          value = dbInfo.serializer.deserialize(value);
        }
        return deferred.resolve(value);
      }, function(error) {
        if (error.code === 2) {
          return deferred.resolve(null);
        }
        return deferred.reject(error);
      });
    }).then(null, deferred.reject);
    return _return(deferred.promise(), callback);
  };

  iterate = function(iterator, callback) {
    var promise, self;
    self = this;
    promise = self.ready().then(function() {
      var dbInfo;
      dbInfo = self._dbInfo;
      return _getKeys(dbInfo).then(function(keys) {
        return _iterate(keys, dbInfo, iterator);
      });
    });
    return _return(promise, callback);
  };

  _iterate = function(keys, dbInfo, iterator, index) {
    var deferred, key;
    if (index == null) {
      index = 0;
    }
    deferred = $.Deferred();
    if (keys.length > 0) {
      key = keys[0];
      NativeStorage.getItem(dbInfo.dataKeyPrefix + key, function(serializedValue) {
        var deserializedValue, iterationResult;
        deserializedValue = dbInfo.serializer.deserialize(serializedValue);
        iterationResult = iterator(deserializedValue, key, index + 1);
        if (iterationResult !== void 0) {
          return deferred.resolve(iterationResult);
        } else {
          return _iterate(keys.slice(1), dbInfo, iterator, index + 1).then(deferred.resolve, deferred.reject);
        }
      }, deferred.reject);
    } else {
      deferred.resolve();
    }
    return _patchPromise(deferred.promise());
  };

  key = function(n, callback) {
    var promise, self;
    self = this;
    promise = self.ready().then(function() {
      return _getKeys(self._dbInfo).then(function(keys) {
        return keys[n];
      });
    });
    return _return(promise, callback);
  };

  keys = function(callback) {
    var promise, self;
    self = this;
    promise = self.ready().then(function() {
      var dbInfo;
      dbInfo = self._dbInfo;
      return _getKeys(dbInfo);
    });
    return _return(promise, callback);
  };

  length = function(callback) {
    var promise, self;
    self = this;
    promise = self.ready().then(function() {
      return _getKeys(self._dbInfo).then(function(keys) {
        return keys.length;
      });
    });
    return _return(promise, callback);
  };

  removeItem = function(key, callback) {
    var deferred, self;
    deferred = $.Deferred();
    self = this;
    self.ready().then(function() {
      var dbInfo;
      dbInfo = self._dbInfo;
      return NativeStorage.remove(dbInfo.dataKeyPrefix + key, function() {
        return _removeKey(key, dbInfo).then(deferred.resolve, deferred.reject);
      }, deferred.reject);
    }, deferred.reject);
    return _return(deferred.promise(), callback);
  };

  setItem = function(key, value, callback) {
    var deferred, self;
    deferred = $.Deferred();
    self = this;
    self.ready().then(function() {
      var dbInfo, originalValue;
      dbInfo = self._dbInfo;
      originalValue = value;
      return dbInfo.serializer.serialize(value, function(serializedValue, error) {
        if (error) {
          return deferred.reject(error);
        } else {
          return NativeStorage.setItem(dbInfo.dataKeyPrefix + key, serializedValue, function(result) {
            return _addKey(key, dbInfo).then(function() {
              return deferred.resolve(originalValue);
            }, deferred.reject);
          }, deferred.reject);
        }
      });
    });
    return _return(deferred.promise(), callback);
  };

  nativeStorageDriver = {
    _driver: 'nativeStorageDriver',
    _support: _support,
    _initStorage: _initStorage,
    clear: clear,
    getItem: getItem,
    iterate: iterate,
    key: key,
    keys: keys,
    length: length,
    setItem: setItem,
    removeItem: removeItem
  };

  module.exports = nativeStorageDriver;

}).call(this);
