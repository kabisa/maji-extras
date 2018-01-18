(function() {
  var _addKey, _clear, _getKeys, _initStorage, _iterate, _removeKey, _return, _setKeys, _support, clear, getItem, iterate, key, keys, length, localforage, nativeStorageDriver, removeItem, setItem;

  localforage = require('localforage');

  _support = function() {
    return Promise.resolve(typeof window.NativeStorage !== 'undefined');
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

  _return = function(promise, callback) {
    if (callback) {
      promise.then(function(result) {
        return callback(null, result);
      }, callback);
    }
    return promise;
  };

  _getKeys = function(dbInfo) {
    return new Promise(function(resolve, reject) {
      return NativeStorage.getItem(dbInfo.metaKeyPrefix + 'keys', function(serializedKeys) {
        var deserializedKeys;
        deserializedKeys = dbInfo.serializer.deserialize(serializedKeys);
        return resolve(deserializedKeys);
      }, reject);
    });
  };

  _setKeys = function(keys, dbInfo) {
    return new Promise(function(resolve, reject) {
      return dbInfo.serializer.serialize(keys, function(serializedKeys, error) {
        if (error) {
          return reject(error);
        } else {
          return NativeStorage.setItem(dbInfo.metaKeyPrefix + 'keys', serializedKeys, resolve, reject);
        }
      });
    });
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
    return new Promise(function(resolve, reject) {
      var key;
      if (keys.length > 0) {
        key = keys[0];
        return NativeStorage.remove(prefix + key, function() {
          return _clear(keys.slice(1), prefix).then(resolve, reject);
        }, reject);
      } else {
        return resolve();
      }
    });
  };

  getItem = function(key, callback) {
    var promise, self;
    self = this;
    promise = new Promise(function(resolve, reject) {
      return self.ready().then(function() {
        var dbInfo;
        dbInfo = self._dbInfo;
        return NativeStorage.getItem(dbInfo.dataKeyPrefix + key, function(value) {
          if (value) {
            value = dbInfo.serializer.deserialize(value);
          }
          return resolve(value);
        }, function(error) {
          if (error.code === 2) {
            return resolve(null);
          }
          return reject(error);
        });
      }).then(null, reject);
    });
    return _return(promise, callback);
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
    if (index == null) {
      index = 0;
    }
    return new Promise(function(resolve, reject) {
      var key;
      if (keys.length > 0) {
        key = keys[0];
        return NativeStorage.getItem(dbInfo.dataKeyPrefix + key, function(serializedValue) {
          var deserializedValue, iterationResult;
          deserializedValue = dbInfo.serializer.deserialize(serializedValue);
          iterationResult = iterator(deserializedValue, key, index + 1);
          if (iterationResult !== void 0) {
            return resolve(iterationResult);
          } else {
            return _iterate(keys.slice(1), dbInfo, iterator, index + 1).then(resolve, reject);
          }
        }, reject);
      } else {
        return resolve();
      }
    });
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
    var promise, self;
    self = this;
    promise = new Promise(function(resolve, reject) {
      return self.ready().then(function() {
        var dbInfo;
        dbInfo = self._dbInfo;
        return NativeStorage.remove(dbInfo.dataKeyPrefix + key, function() {
          return _removeKey(key, dbInfo).then(resolve, reject);
        }, reject);
      }, reject);
    });
    return _return(promise, callback);
  };

  setItem = function(key, value, callback) {
    var promise, self;
    self = this;
    promise = new Promise(function(resolve, reject) {
      return self.ready().then(function() {
        var dbInfo, originalValue;
        dbInfo = self._dbInfo;
        originalValue = value;
        return dbInfo.serializer.serialize(value, function(serializedValue, error) {
          if (error) {
            return reject(error);
          } else {
            return NativeStorage.setItem(dbInfo.dataKeyPrefix + key, serializedValue, function(result) {
              return _addKey(key, dbInfo).then(function() {
                return resolve(originalValue);
              }, reject);
            }, reject);
          }
        });
      });
    });
    return _return(promise, callback);
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
