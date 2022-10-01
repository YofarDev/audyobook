extension TimerUtils on int {
  String getFormatedTimer() {
    final String minuts = "${this ~/ 60}".padLeft(2, '0');
    final String seconds = "${this % 60}".padLeft(2, '0');
    return "$minuts:$seconds";
  }
}
