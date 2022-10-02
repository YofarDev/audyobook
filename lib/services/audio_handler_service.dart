import 'package:just_audio_background/just_audio_background.dart';

class AudioHandlerService {
  static Future<void> init() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.audyobook',
      androidNotificationChannelName: 'Audiobook playback',
      androidNotificationOngoing: true,
    );
  }
}
