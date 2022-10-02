extension TimerUtils on int {
  String getFormatedTimer({bool withHours = false}) {
    final String minuts = "${this ~/ 60}".padLeft(2, '0');
    final String seconds = "${this % 60}".padLeft(2, '0');
    if (withHours) {
      final String hours = "${(this ~/ 60) ~/ 60}".padLeft(2, '0');
      final String minuts2 = "${(this ~/ 60) % 60}".padLeft(2, '0');
      return "${hours}h$minuts2";
    }
    return "$minuts:$seconds";
  }
}
