## terrible-player

This app plays media from the device's local iTunes library and optionally scrobbles it to last.fm.

The only reason to use this is if you really like last.fm and mostly play music from the device's media library (rather than using a streaming service). You will need to provide your own last.fm API key in `config.plist`.

This app was mostly written in 2014, but updated in 2017 after the official iOS last.fm app stopped working altogether. It works with the built in iOS music playing controls in the control center and lock screen.

Known issues:
- It uses a silent background audio task in order to prevent the OS from terminating it so that it can subscribe to media library notifications in the background. This likely prevents it (and similar apps like the official last.fm app) from being accepted to the app store.
- The one time I tried it with CarPlay, the music played correctly, but there was some issue submitting tracks to last.fm which I didn't debug.
- Most of the code was written in 2014 and increasingly needs to be updated.