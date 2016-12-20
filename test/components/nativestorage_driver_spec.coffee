window.$ = window.jquery = require('jquery')
nativeStorageDriver = require('components/nativestorage_driver')

describe 'NativeStorage Driver', ->
  beforeEach ->
    delete nativeStorageDriver._dbInfo

  describe '#_driver', ->
    it 'returns its unique identifier', ->
      expect(nativeStorageDriver._driver).to.eql('nativeStorageDriver')

  describe '#_support', ->
    context 'when NativeStorage is undefined', ->
      it 'returns false', ->
        expect(nativeStorageDriver._support()).to.be.false

    context 'when NativeStorage is defined', ->
      beforeEach ->
        window.NativeStorage = {}

      afterEach ->
        delete window.NativeStorage

      it 'returns true', ->
        expect(nativeStorageDriver._support()).to.be.true

  context 'with a fake implementation of NativeStorage', ->
    beforeEach ->
      window.NativeStorage = nativeStorageFake({})

    afterEach ->
      delete window.NativeStorage

    describe '#_initStorage', ->
      it 'copies the properties of its argument to the _dbInfo property', ->
        nativeStorageDriver._initStorage({ test: 'test' })
          .then ->
            expect(nativeStorageDriver._dbInfo.test).to.eql('test')

      it 'uses the name and store name passed as options to construct the key prefixes', ->
        nativeStorageDriver._initStorage({ name: 'someName', storeName: 'someStoreName' })
          .then ->
            expect(nativeStorageDriver._dbInfo.keyPrefix).to.eql('someName/someStoreName/')
            expect(nativeStorageDriver._dbInfo.dataKeyPrefix).to.eql('someName/someStoreName/data/')
            expect(nativeStorageDriver._dbInfo.metaKeyPrefix).to.eql('someName/someStoreName/meta/')

    context 'with a #ready method that returns a resolved promise', ->
      beforeEach ->
        nativeStorageDriver.ready = -> $.Deferred().resolve()

      context 'with a default name and store name', ->
        beforeEach ->
          nativeStorageDriver._initStorage({ name: 'name', storeName: 'storeName' })

        describe '#getItem', ->
          context 'when a key-value pair is stored', ->
            beforeEach ->
              nativeStorageDriver.setItem('key', 'value')

            it 'returns a promise that is resolved with the value for the given key', ->
              expect(nativeStorageDriver.getItem('key')).to.eventually.equal('value')

            it 'calls the provided callback with the value for the given key', ->
              callback = sinon.spy()
              nativeStorageDriver.getItem('key', callback)
                .then ->
                  expect(callback).to.have.been.calledWith(null, 'value')

          it 'returns a promise that is rejected with an error for an unknown key', ->
            expect(
              nativeStorageDriver.getItem('unknownKey')
            ).to.be.rejectedWith(Error, 'No value found for key \'name/storeName/data/unknownKey\'')

          it 'calls the provided callback with the error for an unknown key', ->
            callback = sinon.spy()
            nativeStorageDriver.getItem('unknownKey', callback)
              .catch ->
                expect(callback).to.have.been.calledOnce
                expect(callback.args[0][0].message).to.eql('No value found for key \'name/storeName/data/unknownKey\'')

        describe '#setItem', ->
          it 'returns a promise that is resolved with the value passed as argument for a valid key', ->
            nativeStorageDriver.setItem('key', 'value')
              .then (storedValue) ->
                expect(storedValue).to.eql('value')
                nativeStorageDriver.getItem('key')
              .then (retrievedValue) ->
                expect(retrievedValue).to.eql('value')

          it 'calls the provided callback with the value passed as argument for a valid key', ->
            callback = sinon.spy()
            nativeStorageDriver.setItem('key', 'value', callback)
              .then ->
                expect(callback).to.have.been.calledWith(null, 'value')
                expect(nativeStorageDriver.getItem('key')).to.eventually.equal('value')

          it 'has no effect on other storages', ->
            nativeStorageDriver.setItem('key', 'value')
              .then (storedValue) ->
                expect(storedValue).to.eql('value')
                nativeStorageDriver.getItem('key')
              .then (retrievedValue) ->
                expect(retrievedValue).to.eql('value')
                nativeStorageDriver._initStorage({ name: 'otherName', storeName: 'otherStoreName' })
              .then ->
                expect(
                  nativeStorageDriver.getItem('key')
                ).to.be.rejectedWith(Error, 'No value found for key \'otherName/otherStoreName/data/key\'')

          it 'returns a promise that is rejected with an error for an invalid key-value pair', ->
            expect(
              nativeStorageDriver.setItem('unstorableKey', 'value')
            ).to.be.rejectedWith(Error, 'Unable to store key \'name/storeName/data/unstorableKey\' and value \'"value"\'')

          it 'calls the provided callback with an error for an invalid key-value pair', ->
            callback = sinon.spy()
            nativeStorageDriver.setItem('unstorableKey', 'value', callback)
              .catch ->
                expect(callback).to.have.been.calledOnce
                expect(callback.args[0][0].message).to.eql('Unable to store key \'name/storeName/data/unstorableKey\' and value \'"value"\'')

        describe '#removeItem', ->
          context 'when a key-value pair is stored', ->
            beforeEach -> nativeStorageDriver.setItem('key', 'value')

            it 'returns a promise that is resolved for the valid key', ->
              expect(nativeStorageDriver.removeItem('key')).to.eventually.fulfill

            it 'calls the provided callback with null as first argument for the valid key', ->
              callback = sinon.spy()
              nativeStorageDriver.removeItem('key', callback)
                .then ->
                  expect(callback).to.have.been.calledWith(null)

          it 'returns a promise that is rejected for an invalid key', ->
            expect(
              nativeStorageDriver.removeItem('unremovableKey')
            ).to.be.rejectedWith(Error, 'Unable to remove value for key \'name/storeName/data/unremovableKey\'')

          it 'calls the provided callback with an error for an invalid key', ->
            callback = sinon.spy()
            nativeStorageDriver.removeItem('unremovableKey', callback)
              .catch ->
                expect(callback).to.have.been.calledOnce
                expect(callback.args[0][0].message).to.eql('Unable to remove value for key \'name/storeName/data/unremovableKey\'')

        describe '#keys', ->
          context 'when a number of key-value pairs are stored', ->
            beforeEach ->
              nativeStorageDriver.setItem('aap', 'boom')
                .then ->
                  nativeStorageDriver.setItem('noot', 'roos')
                .then ->
                  nativeStorageDriver.setItem('mies', 'vis')

            it 'returns a promise that is resolved to an array of keys for the valid prefix', ->
              expect(
                nativeStorageDriver.keys()
              ).to.eventually.eql(['aap', 'noot', 'mies'])

            it 'calls the provided callback with an array of keys for the valid prefix', ->
              callback = sinon.spy()
              nativeStorageDriver.keys(callback)
                .then ->
                  expect(callback).to.have.been.calledWith(null, ['aap', 'noot', 'mies'])

        describe '#length', ->
          context 'when a number of key-value pairs are stored', ->
            beforeEach ->
              nativeStorageDriver.setItem('aap', 'boom')
                .then ->
                  nativeStorageDriver.setItem('noot', 'roos')
                .then ->
                  nativeStorageDriver.setItem('mies', 'vis')

            it 'returns a promise that is resolved to the number of keys for the valid prefix', ->
              expect(
                nativeStorageDriver.length()
              ).to.eventually.eql(3)

            it 'calls the provided callback with the number of keys for the valid prefix', ->
              callback = sinon.spy()
              nativeStorageDriver.length(callback)
                .then ->
                  expect(callback).to.have.been.calledWith(null, 3)

        describe '#key', ->
          context 'when a number of key-value pairs are stored', ->
            beforeEach ->
              nativeStorageDriver.setItem('aap', 'boom')
                .then ->
                  nativeStorageDriver.setItem('noot', 'roos')
                .then ->
                  nativeStorageDriver.setItem('mies', 'vis')

            it 'returns a promise that is resolved to the key at the given index for the valid prefix', ->
              expect(nativeStorageDriver.key(0)).to.eventually.eql('aap')

            it 'calls the provided callback with the key at the given index for the valid prefix', ->
              callback = sinon.spy()
              nativeStorageDriver.key(1, callback)
                .then ->
                  expect(callback).to.have.been.calledWith(null, 'noot')

            it 'returns a promise that resolves to undefined when an out-of-bounds index is provided', ->
              expect(nativeStorageDriver.key(10)).to.eventually.eql(undefined)

            it 'calls the provided callback with undefined when an out-of-bounds index is provided', ->
              callback = sinon.spy()
              nativeStorageDriver.key(10, callback)
                .then ->
                  expect(callback).to.have.been.calledWith(null, undefined)

        describe '#iterate', ->
          context 'when a number of key-value pairs are stored', ->
            beforeEach ->
              nativeStorageDriver.setItem('aap', 'boom')
                .then ->
                  nativeStorageDriver.setItem('noot', 'roos')
                .then ->
                  nativeStorageDriver.setItem('mies', 'vis')

            it 'calls the iterator for each value in storage and returns a promise that is resolved', ->
              values = []
              keys = []
              iterationNumbers = []
              nativeStorageDriver.iterate(
                (value, key, iterationNumber) ->
                  values.push value
                  keys.push key
                  iterationNumbers.push iterationNumber
                  return
              ).then ->
                expect(values).to.eql(['boom', 'roos', 'vis'])
                expect(keys).to.eql(['aap', 'noot', 'mies'])
                expect(iterationNumbers).to.eql([1, 2, 3])

            it 'calls the iterator for each value in storage and the success callback afterwards', ->
              values = []
              keys = []
              iterationNumbers = []
              successCallback = sinon.spy()
              nativeStorageDriver.iterate(
                (value, key, iterationNumber) ->
                  values.push value
                  keys.push key
                  iterationNumbers.push iterationNumber
                  return
                successCallback
              ).then ->
                expect(successCallback).to.have.been.calledOnce
                expect(values).to.eql(['boom', 'roos', 'vis'])
                expect(keys).to.eql(['aap', 'noot', 'mies'])
                expect(iterationNumbers).to.eql([1, 2, 3])

            it 'supports early exit', ->
              nativeStorageDriver.iterate(
                (value, key, iterationNumber) ->
                  return 'some value to force an early exit'
              ).then (value) ->
                expect(value).to.eql('some value to force an early exit')

        describe '#clear', ->
          context 'when a number of key-value pairs are stored', ->
            beforeEach ->
              nativeStorageDriver.setItem('aap', 'boom')
                .then ->
                  nativeStorageDriver.setItem('noot', 'roos')
                .then ->
                  nativeStorageDriver.setItem('mies', 'vis')

            it 'returns a promise that is resolved', ->
              expect(nativeStorageDriver.clear()).to.eventually.fulfill

            it 'calls the provided callback with null as the first argument', ->
              callback = sinon.spy()
              nativeStorageDriver.clear(callback)
                .then ->
                  expect(callback).to.have.been.calledOnce
                  expect(callback.args[0][0]).to.be.null

            it 'removes all key-value pairs', ->
              nativeStorageDriver.clear()
                .then ->
                  nativeStorageDriver.length()
                    .then (length) ->
                      expect(length).to.eql(0)

            context 'with another storage containing key-value pairs', ->
              beforeEach ->
                nativeStorageDriver._initStorage({ name: 'otherName', storeName: 'otherStoreName' })
                  .then ->
                    nativeStorageDriver.setItem('aap', 'boom')
                  .then ->
                    nativeStorageDriver.setItem('noot', 'roos')
                  .then ->
                    nativeStorageDriver.setItem('mies', 'vis')

              it 'only removes the key-value pairs from the current storage', ->
                nativeStorageDriver.clear()
                  .then ->
                    nativeStorageDriver.length()
                  .then (length) ->
                    expect(length).to.eql(0)
                    nativeStorageDriver._initStorage({ name: 'name', storeName: 'storeName' })
                  .then ->
                    nativeStorageDriver.length()
                  .then (length) ->
                    expect(length).to.eql(3)

          context 'when a key-value pair cannot be removed', ->
            beforeEach -> nativeStorageDriver.setItem('unremovableKey', 'value')

            it 'returns a promise that is rejected', ->
              expect(
                nativeStorageDriver.clear()
              ).to.eventually.be.rejectedWith(Error, 'Unable to remove value for key \'name/storeName/data/unremovableKey\'')

            it 'calls the provided callback with an error', ->
              callback = sinon.spy()
              nativeStorageDriver.clear(callback)
                .catch ->
                  expect(callback).to.have.been.calledOnce
                  expect(callback.args[0][0].message).to.eql('Unable to remove value for key \'name/storeName/data/unremovableKey\'')

nativeStorageFake =
  (state) ->
    unstorableKey = 'name/storeName/data/unstorableKey'
    unremovableKey = 'name/storeName/data/unremovableKey'
    {
      getItem: (key, success, error) ->
        value = state[key]
        if (value != undefined)
          success(value)
        else
          error(new Error("No value found for key '#{key}'"))

      setItem: (key, value, success, error) ->
        if key == unstorableKey
          error(new Error("Unable to store key '#{key}' and value '#{value}'"))
        else
          state[key] = value
          success(value)

      remove: (key, success, error) ->
        if key == unremovableKey
          error(new Error("Unable to remove value for key '#{key}'"))
        else
          delete state[key]
          success()
    }
