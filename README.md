# Audyobook (Android & ios)

<img src="https://github.com/YofarDev/audyobook/blob/main/screen_player.jpg" width="300">

Audio files player sync between mobile and desktop made with flutter

## How does it work?

The current position for the current audio file playing is saved on server (on firestore) automatically every 30s, so it can be sync between mobile & desktop apps. The id of the audio file is its path from the "Audiobooks" folder, so it needs to be the same on all devices.

The code source for the desktop app (Linux/Windows) is very similar to this one except for some packages.

## Main libraries used

Audio player and background service :

- [just_audio](https://pub.dev/packages/just_audio)
- [just_audio_background](https://pub.dev/packages/just_audio_background)

Controls from lockscreen & notification center on Android :

<img src="https://github.com/YofarDev/audyobook/blob/main/screen_lockscreen.jpg" width="300"> <img src="https://github.com/YofarDev/audyobook/blob/main/screen_notifcenter.jpg" width="300">
