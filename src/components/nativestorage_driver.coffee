$ = require('jquery')
localforage = require('localforage')

_support = ->
  $.when(typeof window.NativeStorage != 'undefined')

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
        .catch (error) ->
          _setKeys([], dbInfo)

_return = (promise, callback) ->
  if (callback)
    promise.then(
      (result) ->
        callback(null, result)
      callback
    )
  promise.catch ?= promise.fail

  promise

_getKeys = (dbInfo) ->
  deferred = $.Deferred()

  NativeStorage.getItem(
    dbInfo.metaKeyPrefix + 'keys'
    (serializedKeys) ->
      deserializedKeys = dbInfo.serializer.deserialize(serializedKeys)
      deferred.resolve(deserializedKeys)
    deferred.reject
  )

  deferred.promise()

_setKeys = (keys, dbInfo) ->
  deferred = $.Deferred()

  dbInfo.serializer.serialize(
    keys
    (serializedKeys, error) ->
      if (error)
        deferred.reject(error)
      else
        NativeStorage.setItem(
          dbInfo.metaKeyPrefix + 'keys'
          serializedKeys
          deferred.resolve
          deferred.reject
        )
  )

  deferred.promise()

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
  deferred = $.Deferred()

  if (keys.length > 0)
    key = keys[0]
    NativeStorage.remove(
      prefix + key
      ->
        _clear(keys.slice(1), prefix)
          .then deferred.resolve
          .catch deferred.reject
      deferred.reject
    )
  else
    deferred.resolve()

  deferred.promise()

getItem = (key, callback) ->
  deferred = $.Deferred()

  self = this

  self.ready().then ->
    dbInfo = self._dbInfo

    NativeStorage.getItem(
      dbInfo.dataKeyPrefix + key
      (value) ->
        if (value)
          value = dbInfo.serializer.deserialize(value)
        deferred.resolve(value)
      deferred.reject
    )
  .catch deferred.reject

  _return(deferred.promise(), callback)

iterate = (iterator, callback) ->
  self = this

  promise = self.ready().then ->
    dbInfo = self._dbInfo

    _getKeys(dbInfo)
      .then (keys) ->
        _iterate(keys, dbInfo, iterator)

  _return(promise, callback)

_iterate = (keys, dbInfo, iterator, index = 0) ->
  deferred = $.Deferred()

  if (keys.length > 0)
    key = keys[0]
    NativeStorage.getItem(
      dbInfo.dataKeyPrefix + key
      (serializedValue) ->
        deserializedValue = dbInfo.serializer.deserialize(serializedValue)
        iterationResult = iterator(deserializedValue, key, index + 1)

        if (iterationResult != undefined)
          deferred.resolve(iterationResult)
        else
          _iterate(keys.slice(1), dbInfo, iterator, index + 1)
            .then deferred.resolve
            .catch deferred.reject
      deferred.reject
    )
  else
    deferred.resolve()

  deferred.promise()

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
  deferred = $.Deferred()

  self = this

  self.ready().then ->
    dbInfo = self._dbInfo
    NativeStorage.remove(
      dbInfo.dataKeyPrefix + key
      ->
        _removeKey(key, dbInfo)
          .then ->
            deferred.resolve()
          .catch deferred.reject
      deferred.reject
    )
  .catch deferred.reject

  _return(deferred.promise(), callback)

setItem = (key, value, callback) ->
  deferred = $.Deferred()

  self = this

  self.ready().then ->
    dbInfo = self._dbInfo
    originalValue = value

    dbInfo.serializer.serialize(
      value
      (serializedValue, error) ->
        if (error)
          deferred.reject(error)
        else
          NativeStorage.setItem(
            dbInfo.dataKeyPrefix + key
            serializedValue
            (result) ->
              _addKey(key, dbInfo)
                .then ->
                  deferred.resolve(originalValue)
                .catch deferred.reject
            deferred.reject
          )
    )

  _return(deferred.promise(), callback)

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
