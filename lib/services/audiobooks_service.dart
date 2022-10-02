import 'dart:developer';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/audiofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/audiobook.dart';
import '../utils/app_utils.dart';
import 'shared_preferences_service.dart';

class AudiobookService {
  static CollectionReference<Object> firestore =
      FirebaseFirestore.instance.collection('audiobooks');

  static Future<Audiobook> getAudiobook(
    String path, {
    bool forceReload = false,
  }) async {
    final String id = AppUtils.getIdFromPath(path);
    Audiobook? audiobook;
    if (forceReload) {
      audiobook = await getDataFromFile(path);
    } else {
      audiobook = await SharedPreferencesService.getAudiobookFromCache(id);
    }

    return audiobook ??= await getDataFromFile(path);
  }

  static Future<Audiobook> getDataFromFile(String path) async {
    final Audiotagger tagger = Audiotagger();
    final AudioFile? audio = await tagger.readAudioFile(path: path);
    final Duration duration = Duration(seconds: audio?.length ?? 0);
    final String artworkPath = await getArtworkPath(path);

    final Audiobook audiobook = Audiobook(
      id: AppUtils.getIdFromPath(path),
      path: path,
      name: AppUtils.getNameFromPath(path),
      album: AppUtils.getAlbumFromPath(path),
      duration: duration,
      currentPosition: Duration.zero,
      artworkPath: artworkPath,
    );

    audiobook.currentPosition = await getPositionFromServer(audiobook.id);
    audiobook.completed = audiobook.currentPosition == audiobook.duration;

    await SharedPreferencesService.saveAudiobookInCache(audiobook);

    return audiobook;
  }

  static Future<void> savePositionToServer(String id, Duration position) async {
    final int p = position.inSeconds;
    firestore.doc(id).set(<String, int>{'position': p});
    log("(saved to firestore) $id : $position");
  }

  static Future<Duration> getPositionFromServer(String id) async {
    try {
      final DocumentSnapshot<Object> value = await firestore.doc(id).get();
      final Map<String, dynamic> map = value.data()! as Map<String, dynamic>;
      return Duration(seconds: map['position'] as int? ?? 0);
      
    } catch (e) {
      return Duration.zero;
    }
  }

  static Future<String> getArtworkPath(String path) async {
    final String albumId = AppUtils.getAlbumIdFromPath(path);
    String? artworkPath;
    artworkPath = await SharedPreferencesService.getArtworkPath(albumId);
    if (artworkPath == null) {
      final Audiotagger tagger = Audiotagger();
      final Uint8List? bytes = await tagger.readArtwork(path: path);
      if (bytes == null) {
        return "";
      }
      artworkPath = await AppUtils.createFileForArtwork(bytes, albumId);
    }
    return artworkPath;
  }
}
