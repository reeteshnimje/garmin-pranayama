# Garmin Official References

Use these before changing APIs, manifest settings, persistence, timers, input, or vibration behavior.

- Application lifecycle: <https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/AppBase.html>
- Persistent local storage: <https://developer.garmin.com/connect-iq/api-docs/Toybox/Application/Storage.html>
- Watch UI views: <https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/View.html>
- View navigation and updates: <https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi.html>
- Device-independent input: <https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/BehaviorDelegate.html>
- Repeating timers: <https://developer.garmin.com/connect-iq/api-docs/Toybox/Timer/Timer.html>
- Attention and vibration entry point: <https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html>
- Vibration profile shape: <https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention/VibeProfile.html>
- Compatible device matrix: <https://developer.garmin.com/connect-iq/compatible-devices/>

Notes from the official docs used in this implementation:

- `Application.Storage` persists arrays and dictionaries, but keys/values must be persistable types and each stored value is limited to 32 KB.
- `Attention.vibrate()` should be guarded with `Attention has :vibrate`; `VibeProfile` uses duty cycle plus length in milliseconds.
- `Timer.Timer.start(callback, time, repeat)` takes milliseconds and can run as a repeating timer until `stop()`.
- `BehaviorDelegate` maps select/up/down/back/menu behavior across buttons and touch, which is preferable to hard-coding Forerunner button IDs.
- Garmin’s compatible-device matrix lists Forerunner 265 as 416 x 416 round AMOLED with API level 5.2.
