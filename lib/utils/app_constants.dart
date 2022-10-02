import 'dart:io';

class AppConstants {
  static String getSlash() {
    if (Platform.isWindows) return '\\';
    return '/';
  }
}
