import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/audiobook.dart';

class SharedPreferencesService {
  static Future<void> saveAudiobookInCache(Audiobook audiobook) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    log("(saved locally) ${audiobook.id} : ${audiobook.currentPosition}");
    await prefs.setString(
      audiobook.id,
      jsonEncode(audiobook.toMap()),
    );
  }

  static Future<Audiobook?> getAudiobookFromCache(String audiobookId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(audiobookId);
    if (json == null) {
      return null;
    } else {
      return Audiobook.fromMap(
        jsonDecode(json) as Map<String, dynamic>,
      );
    }
  }

  static Future<String?> getArtworkPath(String albumId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString("artwork_$albumId");
    if (path == null) {
      return null;
    } else {
      return path;
    }
  }

  static Future<void> setArtworkPath(String albumId, String artworkPath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("artwork_$albumId", artworkPath);
  }
}
