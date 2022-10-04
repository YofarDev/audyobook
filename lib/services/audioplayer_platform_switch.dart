import 'dart:io';

import 'package:audioplayers/audioplayers.dart' as desktop;
import 'package:just_audio/just_audio.dart';

import '../models/audiobook.dart';

class AudioplayerPlatformSwitch {
  // ignore: always_specify_types, prefer_typing_uninitialized_variables, type_annotate_public_apis
  static late var player;

  static void init() {
    if (Platform.isAndroid || Platform.isIOS) {
      player = AudioPlayer();
    } else {
      player = desktop.AudioPlayer();
    }
  }

  static Stream<Duration> getPositionStream() {
    if (Platform.isAndroid || Platform.isIOS) {
      return (player as AudioPlayer).positionStream;
    } else {
      return (player as desktop.AudioPlayer).onPositionChanged;
    }
  }

  static Future<Duration?> getCurrentPosition() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return (player as AudioPlayer).position;
    } else {
      return (player as desktop.AudioPlayer).getCurrentPosition();
    }
  }

  static Future<void> setAudioSource(Audiobook audiobook) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await (player as AudioPlayer).setAudioSource(audiobook.toAudioSource());
    } else {
      await (player as desktop.AudioPlayer)
          .play(desktop.DeviceFileSource(audiobook.path));
    }
  }

  static Future<void> setSpeed(double speed) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await (player as AudioPlayer).setSpeed(speed);
    } else {
      await (player as desktop.AudioPlayer).setPlaybackRate(speed);
    }
  }

  static void play() {
    if (Platform.isAndroid || Platform.isIOS) {
      (player as AudioPlayer).play();
    } else {
      (player as desktop.AudioPlayer).resume();
    }
  }

  static void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      (player as AudioPlayer).dispose();
    } else {
      (player as desktop.AudioPlayer).release();
    }
  }
}
