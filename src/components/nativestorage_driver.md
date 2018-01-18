## Localforage Driver for NativeStorage

Out of the box, Localforage supports storing data with LocalStorage, IndexedDB, and WebSQL.

[NativeStorage](https://github.com/TheCocoaProject/cordova-plugin-nativestorage) is a Cordova plug-in for persistent storage of data on Android, iOS, and Windows devices.
Use this driver to interact with the NativeStorage plug-in using the Localforage API.

## Usage

This driver uses native Promises. Depending on the browser support requirements for your project, you might have to use a Promise polyfill.

This driver depends on the NativeStorage Cordova plug-in.
Install the plug-in by including the following line in `config.xml`:

```xml
<plugin name="cordova-plugin-nativestorage" spec="~2.1.0" />
```

Instruct Localforage to use this driver as follows:

```coffee
localforage = require('localforage')
nativeStorageDriver = require('maji-extras/lib/components/nativestorage_driver')

localforage.defineDriver(nativeStorageDriver)
  .then(
    ->
      localforage.setDriver(['nativeStorageDriver'])
        .then(
          ->
            console.log 'Using NativeStorage driver for Localforage'
          (error) ->
            console.error 'Unable to set driver for Localforage'
            console.error error
        )
    (error) ->
      console.error 'Unable to define driver for Localforage'
      console.error error
  )
```

The NativeStorage plug-in is available after the [deviceready](https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready) event has fired.
You should postpone the execution of the code above until after this event has fired.
