import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class AppUtils {
// Path example :
//       "/storage/6639-6132/Documents/Audiobooks/Game of thrones/Tome 2/02 BRAN.mp3"

  static String getIdFromPath(String path) {
    return path
        .substring(path.lastIndexOf("/Audiobooks/") + 11)
        .replaceAll('/', '||')
        .replaceAll(' ', '_');
  }

  static String getAlbumIdFromPath(String path) {
    return getAlbumFromPath(path).replaceAll(' ', '_');
  }

  static String getNameFromPath(String path) =>
      path.substring(path.lastIndexOf("/") + 1);

  static String getAlbumFromPath(String path) => path
      .substring(
        path.lastIndexOf("/Audiobooks/") + 12,
        path.lastIndexOf('/'),
      )
      .replaceAll('/', ' - ');

  static Future<String> createFileForArtwork(
    Uint8List bytes,
    String albumId,
  ) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = "${dir.path}/artwork_$albumId.png";
    final File f = File(path);
    f.writeAsBytesSync(bytes);
    return path;
  }
}
