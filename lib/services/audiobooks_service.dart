import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/audiofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:firedart/firestore/models.dart' as desktop;
import 'package:id3tag/id3tag.dart';
import 'package:mp3_info/mp3_info.dart';

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
    Duration duration;
    String artworkPath;
    // MOBILE
    if (Platform.isAndroid || Platform.isIOS) {
      final Audiotagger tagger = Audiotagger();
      final AudioFile? audio = await tagger.readAudioFile(path: path);

      duration = Duration(seconds: audio?.length ?? 0);
      artworkPath = await getArtworkPath(path);

      // DESKTOP
    } else {
      final File f = File(path);
      final MP3Info mp3 = MP3Processor.fromFile(f);
      final ID3TagReader parser = ID3TagReader.path(path);
      final ID3Tag tag = parser.readTagSync();
      final Uint8List bytes = tag.pictures.single.imageData as Uint8List;

      artworkPath = await getArtworkPath(path, desktopBytes: bytes);
      duration = mp3.duration;
    }

    final Audiobook audiobook = Audiobook(
      id: AppUtils.getIdFromPath(path),
      path: path,
      name: AppUtils.getNameFromPath(path),
      album: AppUtils.getAlbumFromPath(path),
      duration: duration,
      currentPosition: Duration.zero,
      artworkPath: artworkPath,
    );

    await SharedPreferencesService.saveAudiobookInCache(audiobook);

    return audiobook;
  }

  static Future<void> savePositionToServer(
    Audiobook audiobook,
    Duration position,
  ) async {
    final int p = position.inSeconds;
    // MOBILE
    if (Platform.isAndroid || Platform.isIOS) {
      firestore
          .doc(audiobook.album)
          .collection("saved")
          .doc(audiobook.id)
          .set(<String, int>{'position': p});
      // DESKTOP
    } else {
      Firestore.instance
          .collection("audiobooks")
          .document(audiobook.album)
          .collection("saved")
          .document(audiobook.id)
          .set(<String, int>{'position': p});
    }
    log("(saved to firestore) ${audiobook.id} : $position");
  }

  static Future<Duration> getPositionFromServer(Audiobook audiobook) async {
    try {
      // MOBILE
      if (Platform.isAndroid || Platform.isIOS) {
        final DocumentSnapshot<Object> value = await firestore
            .doc(audiobook.album)
            .collection("saved")
            .doc(audiobook.id)
            .get();
        final Map<String, dynamic> map = value.data()! as Map<String, dynamic>;
        return Duration(seconds: map['position'] as int? ?? 0);

        // DESKTOP
      } else {
        final desktop.Document doc = await Firestore.instance
            .collection("audiobooks")
            .document(audiobook.album)
            .collection("saved")
            .document(audiobook.id)
            .get();
        return Duration(seconds: doc.map['position'] as int? ?? 0);
      }
    } catch (e) {
      return Duration.zero;
    }
  }

  static Future<String> getArtworkPath(
    String path, {
    Uint8List? desktopBytes,
  }) async {
    final String albumId = AppUtils.getAlbumIdFromPath(path);
    String? artworkPath;
    artworkPath = await SharedPreferencesService.getArtworkPath(albumId);
    if (artworkPath == null) {
      Uint8List? bytes;
      if (desktopBytes == null) {
        final Audiotagger tagger = Audiotagger();
        bytes = await tagger.readArtwork(path: path);
      } else {
        bytes = desktopBytes;
      }

      if (bytes == null) {
        return "";
      }
      artworkPath = await AppUtils.createFileForArtwork(bytes, albumId);
    }
    return artworkPath;
  }

  static Future<Map<String, Duration>> getAllPostionsForAlbum(
      String album,) async {
    final Map<String, Duration> map = <String, Duration>{};
    // MOBILE
    if (Platform.isAndroid || Platform.isIOS) {
      final QuerySnapshot<Map<String, dynamic>> data =
          await firestore.doc(album).collection("saved").get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in data.docs) {
        map.putIfAbsent(
          doc.id,
          () => Duration(seconds: doc['position'] as int? ?? 0),
        );
      }
      // DESKTOP
    } else {
      final desktop.Page<desktop.Document> data = await Firestore.instance
          .collection("audiobooks")
          .document(album)
          .collection("saved")
          .get();
      for (final desktop.Document doc in data) {
        map.putIfAbsent(
          doc.id,
          () => Duration(seconds: doc['position'] as int? ?? 0),
        );
      }
    }
    return map;
  }
}
