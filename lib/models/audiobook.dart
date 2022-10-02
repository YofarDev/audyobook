import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class Audiobook {
  String id;
  String path;
  String name;
  String album;
  Duration duration;
  Duration currentPosition;
  String? artworkPath;
  late int index;
  late bool completed;

  Audiobook({
    required this.id,
    required this.path,
    required this.name,
    required this.album,
    required this.duration,
    required this.currentPosition,
    this.artworkPath,
  });

  AudioSource toAudioSource() {
    return AudioSource.uri(
      Uri.parse(path),
      tag: MediaItem(
        id: id,
        album: album,
        title: name,
        artUri: Uri.parse("file://$artworkPath"),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    // final String? artworkStr =
    //     artwork != null ? String.fromCharCodes(artwork!) : null;
    return <String, dynamic>{
      'id': id,
      'path': path,
      'name': name,
      'album': album,
      'duration': duration.inSeconds,
      'currentPosition': currentPosition.inSeconds,
      'artworkPath': artworkPath,
    };
  }

  factory Audiobook.fromMap(Map<String, dynamic> map) {
    // final String? artworkString = map['artwork'] as String?;
    // final Uint8List? artwork = artworkString != null
    //     ? Uint8List.fromList(artworkString.codeUnits)
    //     : null;
    return Audiobook(
      id: map['id'] as String,
      path: map['path'] as String,
      name: map['name'] as String,
      album: map['album'] as String,
      duration: Duration(seconds: map['duration'] as int),
      currentPosition: Duration(seconds: map['currentPosition'] as int),
      artworkPath: map['artworkPath'] as String?,
    );
  }

  @override
  String toString() {
    return 'Audiobook(id: $id, path: $path, name: $name, album : $album, duration: $duration, currentPosition: $currentPosition, artworkPath : $artworkPath)';
  }
}
