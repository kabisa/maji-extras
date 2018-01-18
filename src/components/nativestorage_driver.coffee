localforage = require('localforage')

_support = ->
  Promise.resolve(typeof window.NativeStorage != 'undefined')

_initStorage = (options) ->
  self = this
  dbInfo = {}

  if (options)
    for key, value of options
      dbInfo[key] = options[key]

  dbInfo.keyPrefix = dbInfo.name + '/' + dbInfo.storeName + '/'
  dbInfo.dataKeyPrefix = dbInfo.keyPrefix + 'data/'
  dbInfo.metaKeyPrefix = dbInfo.keyPrefix + 'meta/'

  self._dbInfo = dbInfo

  localforage.getSerializer()
    .then (serializer) ->
      dbInfo.serializer = serializer
      _getKeys(dbInfo)
        .then(
          null,
          (error) -> _setKeys([], dbInfo)
        )

_return = (promise, callback) ->
  if (callback)
    promise.then(
      (result) ->
        callback(null, result)
      callback
    )
  promise

_getKeys = (dbInfo) ->
  new Promise((resolve, reject) ->
    NativeStorage.getItem(
      dbInfo.metaKeyPrefix + 'keys'
      (serializedKeys) ->
        deserializedKeys = dbInfo.serializer.deserialize(serializedKeys)
        resolve(deserializedKeys)
      reject
    )
  )

_setKeys = (keys, dbInfo) ->
  new Promise((resolve, reject) ->
    dbInfo.serializer.serialize(
      keys
      (serializedKeys, error) ->
        if (error)
          reject(error)
        else
          NativeStorage.setItem(
            dbInfo.metaKeyPrefix + 'keys'
            serializedKeys
            resolve
            reject
          )
    )
  )

_addKey = (key, dbInfo) ->
  _getKeys(dbInfo)
    .then (keys) ->
      index = keys.indexOf(key)
      if (index == -1)
        keys.push(key)
        _setKeys(keys, dbInfo)

_removeKey = (key, dbInfo) ->
  _getKeys(dbInfo)
    .then (keys) ->
      index = keys.indexOf(key)
      return if (index == -1)
      keys.splice(index, 1)
      _setKeys(keys, dbInfo)

clear = (callback) ->
  self = this

  p = self.ready().then ->
    dbInfo = self._dbInfo

    _getKeys(dbInfo)
      .then (keys) ->
        _clear(keys, dbInfo.dataKeyPrefix)
      .then ->
        _setKeys([], dbInfo)

  _return(p, callback)

_clear = (keys, prefix) ->
  new Promise((resolve, reject) ->
    if (keys.length > 0)
      key = keys[0]
      NativeStorage.remove(
        prefix + key
        ->
          _clear(keys.slice(1), prefix)
            .then(resolve, reject)
        reject
      )
    else
      resolve()
  )

getItem = (key, callback) ->
  self = this

  promise = new Promise((resolve, reject) ->
    self.ready().then ->
      dbInfo = self._dbInfo

      NativeStorage.getItem(
        dbInfo.dataKeyPrefix + key
        (value) ->
          if (value)
            value = dbInfo.serializer.deserialize(value)
          resolve(value)
        (error) ->
          # https://github.com/TheCocoaProject/cordova-plugin-nativestorage#error-codes
          return resolve(null) if error.code is 2 # ITEM_NOT_FOUND
          reject(error)
      )
    .then(null, reject)
  )

  _return(promise, callback)



iterate = (iterator, callback) ->
  self = this

  promise = self.ready().then ->
    dbInfo = self._dbInfo

    _getKeys(dbInfo)
      .then (keys) ->
        _iterate(keys, dbInfo, iterator)

  _return(promise, callback)

_iterate = (keys, dbInfo, iterator, index = 0) ->
  new Promise((resolve, reject) ->
    if (keys.length > 0)
      key = keys[0]
      NativeStorage.getItem(
        dbInfo.dataKeyPrefix + key
        (serializedValue) ->
          deserializedValue = dbInfo.serializer.deserialize(serializedValue)
          iterationResult = iterator(deserializedValue, key, index + 1)

          if (iterationResult != undefined)
            resolve(iterationResult)
          else
            _iterate(keys.slice(1), dbInfo, iterator, index + 1)
              .then(resolve, reject)
        reject
      )
    else
      resolve()
  )

key = (n, callback) ->
  self = this

  promise = self.ready().then ->
    _getKeys(self._dbInfo)
      .then (keys) ->
        return keys[n]

  _return(promise, callback)

keys = (callback) ->
  self = this

  promise = self.ready().then ->
    dbInfo = self._dbInfo
    _getKeys(dbInfo)

  _return(promise, callback)

length = (callback) ->
  self = this

  promise = self.ready().then ->
    _getKeys(self._dbInfo)
      .then (keys) ->
        return keys.length

  _return(promise, callback)

removeItem = (key, callback) ->
  self = this

  promise = new Promise((resolve, reject) ->
    self.ready().then(
      ->
        dbInfo = self._dbInfo
        NativeStorage.remove(
          dbInfo.dataKeyPrefix + key
          ->
            _removeKey(key, dbInfo)
              .then(resolve, reject)
          reject
        )
      reject
    )
  )

  _return(promise, callback)

setItem = (key, value, callback) ->
  self = this

  promise = new Promise((resolve, reject) ->
    self.ready().then ->
      dbInfo = self._dbInfo
      originalValue = value

      dbInfo.serializer.serialize(
        value
        (serializedValue, error) ->
          if (error)
            reject(error)
          else
            NativeStorage.setItem(
              dbInfo.dataKeyPrefix + key
              serializedValue
              (result) ->
                _addKey(key, dbInfo)
                  .then(
                    -> resolve(originalValue)
                    reject
                  )
              reject
            )
      )
  )

  _return(promise, callback)

nativeStorageDriver =
  _driver: 'nativeStorageDriver'
  _support: _support
  _initStorage: _initStorage
  clear: clear
  getItem: getItem
  iterate: iterate
  key: key
  keys: keys
  length: length
  setItem: setItem
  removeItem: removeItem

module.exports = nativeStorageDriver
