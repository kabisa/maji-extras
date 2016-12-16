localforage = require('localforage')
whenjs = require('when')

_support = ->
  whenjs(typeof window.NativeStorage != 'undefined')

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

  promise = whenjs.promise(
    (resolve, reject) ->
      localforage.getSerializer()
        .then (serializer) ->
          dbInfo.serializer = serializer
          _getKeys(dbInfo)
            .then ->
              resolve()
            .catch (error) ->
              _setKeys([], dbInfo)
                .then ->
                  resolve()
                .catch (error) ->
                  reject(error)
        .catch (error) ->
          reject(error)
  )

  promise

_return = (promise, callback) ->
  if (callback)
    promise.then(
      (result) ->
        callback(null, result)
      (error) ->
        callback(error)
    )

  promise

_getKeys = (dbInfo) ->
  promise = whenjs.promise(
    (resolve, reject) ->
      NativeStorage.getItem(
        dbInfo.metaKeyPrefix + 'keys'
        (serializedKeys) ->
          deserializedKeys = dbInfo.serializer.deserialize(serializedKeys)
          resolve(deserializedKeys)
        (error) ->
          reject(error)
      )
  )

  promise

_setKeys = (keys, dbInfo) ->
  promise = whenjs.promise(
    (resolve, reject) ->
      dbInfo.serializer.serialize(
        keys
        (serializedKeys, error) ->
          if (error)
            reject(error)
          else
            NativeStorage.setItem(
              dbInfo.metaKeyPrefix + 'keys'
              serializedKeys
              -> resolve()
              (error) ->
                reject(error)
            )
      )
  )

  promise

_addKey = (key, dbInfo) ->
  promise = whenjs.promise(
    (resolve, reject) ->
      _getKeys(dbInfo)
        .then (keys) ->
          index = keys.indexOf(key)
          if (index == -1)
            keys.push(key)
            _setKeys(keys, dbInfo)
              .then ->
                resolve()
              .catch (error) ->
                reject(error)
          else
            resolve()
        .catch (error) ->
          reject(error)
  )

  promise

_removeKey = (key, dbInfo) ->
  promise = whenjs.promise(
    (resolve, reject) ->
      _getKeys(dbInfo)
        .then (keys) ->
          index = keys.indexOf(key)
          if (index == -1)
            resolve()
          else
            keys.splice(index, 1)
            _setKeys(keys, dbInfo)
              .then ->
                resolve()
              .catch (error) ->
                reject(error)
        .catch (error) ->
          reject(error)
  )

  promise

clear = (callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          dbInfo = self._dbInfo

          _getKeys(dbInfo)
            .then (keys) ->
              _clear(keys, dbInfo.dataKeyPrefix)
                .then ->
                  _setKeys([], dbInfo)
                    .then ->
                      resolve()
                    .catch (error) ->
                      reject(error)
                .catch (error) ->
                  reject(error)
            .catch (error) ->
              reject(error)
      )
  )

  _return(promise, callback)

_clear = (keys, prefix) ->
  promise = whenjs.promise(
    (resolve, reject) ->
      if (keys.length > 0)
        key = keys[0]
        NativeStorage.remove(
          prefix + key
          ->
            _clear(keys.slice(1), prefix)
              .then ->
                resolve()
              .catch (error) ->
                reject(error)
          (error) ->
            reject(error)
        )
      else
        resolve()
  )

  promise

getItem = (key, callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          dbInfo = self._dbInfo

          NativeStorage.getItem(
            dbInfo.dataKeyPrefix + key
            (value) ->
              if (value)
                value = dbInfo.serializer.deserialize(value)
              resolve(value)
            (error) ->
              reject(error)
          )
      )
  )

  _return(promise, callback)

iterate = (iterator, callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          dbInfo = self._dbInfo

          _getKeys(dbInfo)
            .then (keys) ->
              _iterate(keys, dbInfo, iterator)
                .then (result) ->
                  resolve(result)
                .catch (error) ->
                  reject(error)
            .catch (error) ->
              reject(error)
      )
  )

  _return(promise, callback)

_iterate = (keys, dbInfo, iterator, index = 0) ->
  promise = whenjs.promise(
    (resolve, reject) ->
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
                .then(
                  (result) ->
                    resolve(result)
                ).catch(
                  (error) ->
                    reject(error)
                )
          (error) ->
            reject(error)
        )
      else
        resolve()
  )

  promise

key = (n, callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          _getKeys(self._dbInfo)
            .then (keys) ->
              resolve(keys[n])
            .catch (error) ->
              reject(error)
      )
  )

  _return(promise, callback)

keys = (callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          dbInfo = self._dbInfo

          _getKeys(dbInfo)
            .then (keys) ->
              resolve(keys)
            .catch (error) ->
              reject(error)
      )
  )

  _return(promise, callback)

length = (callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          _getKeys(self._dbInfo)
            .then (keys) ->
              resolve(keys.length)
            .catch (error) ->
              reject(error)
      )
  )

  _return(promise, callback)

removeItem = (key, callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
          dbInfo = self._dbInfo
          NativeStorage.remove(
            dbInfo.dataKeyPrefix + key
            ->
              _removeKey(key, dbInfo)
                .then ->
                  resolve()
                .catch (error) ->
                  reject(error)
            (error) -> reject(error)
          )
      )
  )

  _return(promise, callback)

setItem = (key, value, callback) ->
  self = this

  promise = whenjs.promise(
    (resolve, reject) ->
      self.ready().then(
        ->
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
                      .then ->
                        resolve(originalValue)
                      .catch (error) ->
                        reject(error)
                  (error) ->
                    reject(error)
                )
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
